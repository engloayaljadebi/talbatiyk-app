import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'legacy_ownership_schema_fixture.dart';
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  group('AppDatabase migrations', () {
    test('migrates persisted data from v6 through v15 without loss', () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'talbatiyk-drift-v6-v7-',
      );

      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final databaseFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}migration.sqlite',
      );

      await _createExactV6Fixture(databaseFile);

      final database = AppDatabase.forTesting(NativeDatabase(databaseFile));

      try {
        // First real query must trigger the direct v6 -> v7 migration.
        final notifications = await database
            .select(database.notificationRecords)
            .get();

        final orders = await database.select(database.orderRecords).get();

        final operations = await database.select(database.syncOperations).get();

        // Existing tables must still be queryable after the migration.
        await database.select(database.productRecords).get();
        await database.select(database.productDiscoveryRecords).get();
        await database.select(database.orderItemRecords).get();
        await database.select(database.cartItemRecords).get();

        // Confirm the historical cart item survives v6 -> v15.
        final oldCartRows = await database
            .customSelect(
              'SELECT i.product_id, i.product_name, i.price, '
              'i.cart_quantity, c.owner_user_id '
              'FROM cart_item_records i '
              'JOIN cart_records c ON c.id = i.cart_id '
              "WHERE i.product_id = 'legacy-v6-product';",
            )
            .get();

        expect(oldCartRows, hasLength(1));
        expect(
          oldCartRows.single.read<String>('product_name'),
          'Historical product',
        );
        expect(oldCartRows.single.read<double>('price'), 250);
        expect(oldCartRows.single.read<int>('cart_quantity'), 3);
        expect(oldCartRows.single.data['owner_user_id'], isNull);

        final foreignKeyErrors = await database
            .customSelect('PRAGMA foreign_key_check;')
            .get();

        expect(foreignKeyErrors, isEmpty);

        expect(database.schemaVersion, 16);

        // v7 table was created by MigrationStrategy and starts empty.
        expect(notifications, isEmpty);

        // Existing v6 business data survives unchanged.
        expect(orders, hasLength(1));
        expect(orders.single.id, 'legacy-v6-order');
        expect(orders.single.status, 'delivered');
        expect(orders.single.notes, 'preserve-me');

        expect(operations, hasLength(1));
        expect(operations.single.id, 'order:create:legacy-v6-order');
        expect(operations.single.entityId, 'legacy-v6-order');
        expect(operations.single.status, SyncOperationStatuses.retrying);
        expect(operations.single.attempts, 3);
        expect(operations.single.lastError, 'temporary v6 failure');

        // Composite {userId, id} primary key must allow the same
        // server notification UUID to be cached for separate users.
        final now = DateTime.utc(2026, 9, 20, 15);

        await database
            .into(database.notificationRecords)
            .insert(
              NotificationRecordsCompanion.insert(
                userId: 'user-a',
                id: 'shared-notification-id',
                type: 'migration_probe',
                title: 'User A',
                body: 'Migration probe',
                createdAt: now,
                updatedAt: now,
              ),
            );

        await database
            .into(database.notificationRecords)
            .insert(
              NotificationRecordsCompanion.insert(
                userId: 'user-b',
                id: 'shared-notification-id',
                type: 'migration_probe',
                title: 'User B',
                body: 'Migration probe',
                createdAt: now,
                updatedAt: now,
              ),
            );

        final migratedNotifications = await database
            .select(database.notificationRecords)
            .get();

        expect(migratedNotifications, hasLength(2));
        expect(migratedNotifications.map((row) => row.userId).toSet(), <String>{
          'user-a',
          'user-b',
        });
      } finally {
        await database.close();
      }

      expect(_readUserVersion(databaseFile), 16);
    });
  });
}

/// Builds the exact schema through the real AppDatabase first, then converts
/// it to the historical v6 boundary.
///
/// Repository history proves v7 differs from v6 only by NotificationRecords,
/// so removing that table and restoring user_version=6 produces the real
/// migration boundary without maintaining a handwritten duplicate v6 schema.
Future<void> _createExactV6Fixture(File file) async {
  final currentDatabase = AppDatabase.forTesting(NativeDatabase(file));

  try {
    // Force Drift to create the complete current schema.
    await currentDatabase.select(currentDatabase.orderRecords).get();
  } finally {
    await currentDatabase.close();
  }

  final rawDatabase = sqlite.sqlite3.open(file.path);

  try {
    final currentVersion = _userVersion(rawDatabase);

    if (currentVersion != 16) {
      throw StateError(
        'Fixture precondition failed: expected current schema v15, '
        'found v$currentVersion.',
      );
    }

    rawDatabase.execute('DROP TABLE notification_records;');

    // A v6 database must not contain the tables introduced in v15.
    final originalCartCount =
        rawDatabase
                .select('SELECT COUNT(*) AS total FROM cart_records;')
                .single['total']
            as int;

    final originalItemCount =
        rawDatabase
                .select('SELECT COUNT(*) AS total FROM cart_item_records;')
                .single['total']
            as int;

    if (originalCartCount != 0 || originalItemCount != 0) {
      throw StateError('Fixture bootstrap unexpectedly contains cart data.');
    }

    rawDatabase.execute('DROP TABLE cart_item_records;');
    rawDatabase.execute('DROP TABLE cart_records;');

    // Reconstruct the pre-v15 cart table rather than leaving
    // the new multi-cart schema in a database marked as v6.
    rawDatabase.execute('''
      CREATE TABLE cart_item_records (
        product_id TEXT NOT NULL PRIMARY KEY,
        supplier_id TEXT NOT NULL DEFAULT '',
        supplier_name TEXT NOT NULL DEFAULT '',
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT NOT NULL DEFAULT '',
        local_image_path TEXT,
        category TEXT NOT NULL DEFAULT '',
        brand TEXT NOT NULL DEFAULT '',
        is_available INTEGER NOT NULL DEFAULT 1,
        description TEXT NOT NULL DEFAULT '',
        colors_json TEXT NOT NULL DEFAULT '[]',
        product_quantity INTEGER NOT NULL DEFAULT 0,
        discount REAL NOT NULL DEFAULT 0,
        rating REAL NOT NULL DEFAULT 0,
        sync_status TEXT NOT NULL DEFAULT 'synced',
        sync_error TEXT,
        product_created_at INTEGER,
        product_updated_at INTEGER,
        cart_quantity INTEGER NOT NULL,
        sort_order INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    rawDatabase.execute('''
      INSERT INTO cart_item_records (
        product_id, product_name, price,
        cart_quantity, sort_order, updated_at
      ) VALUES (
        'legacy-v6-product', 'Historical product',
        250, 3, 0, 1789912800
      );
    ''');

    rawDatabase.execute(
      '''
      INSERT INTO order_records (
        id,
        status,
        aggregate_status,
        notes,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?, ?);
      ''',
      <Object?>[
        'legacy-v6-order',
        'delivered',
        'pending_responses',
        'preserve-me',
        1789912800,
        1789912800,
      ],
    );

    rawDatabase.execute(
      '''
      INSERT INTO sync_operations (
        id,
        entity_type,
        entity_id,
        operation,
        payload_json,
        status,
        attempts,
        last_error,
        next_attempt_at,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);
      ''',
      <Object?>[
        'order:create:legacy-v6-order',
        'order',
        'legacy-v6-order',
        'create',
        '{"legacyV6":true}',
        'retrying',
        3,
        'temporary v6 failure',
        null,
        1789912800,
      ],
    );

    removeV13OwnershipColumnsFromLegacyFixture(rawDatabase);
    rawDatabase.execute('PRAGMA user_version = 6;');

    final remainingNotificationTables = rawDatabase.select('''
      SELECT name
      FROM sqlite_master
      WHERE type = 'table'
        AND name = 'notification_records';
      ''');

    if (remainingNotificationTables.isNotEmpty) {
      throw StateError(
        'Fixture precondition failed: notification_records still exists.',
      );
    }

    final downgradedVersion = _userVersion(rawDatabase);

    if (downgradedVersion != 6) {
      throw StateError(
        'Fixture precondition failed: expected user_version 6, '
        'found $downgradedVersion.',
      );
    }
  } finally {
    rawDatabase.close();
  }
}

int _readUserVersion(File file) {
  final database = sqlite.sqlite3.open(file.path);

  try {
    return _userVersion(database);
  } finally {
    database.close();
  }
}

int _userVersion(sqlite.Database database) {
  final rows = database.select('PRAGMA user_version;');

  if (rows.length != 1) {
    throw StateError('Expected exactly one PRAGMA user_version row.');
  }

  final value = rows.single['user_version'];

  if (value is! int) {
    throw StateError('Expected integer PRAGMA user_version, found $value.');
  }

  return value;
}

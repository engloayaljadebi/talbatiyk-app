import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  group('AppDatabase migrations', () {
    test('migrates persisted data from v4 to v6 without loss', () async {
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'talbatiyk-drift-migration-',
      );

      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final File databaseFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}migration.sqlite',
      );

      _createLegacyV4Database(databaseFile);

      final AppDatabase database = AppDatabase.forTesting(
        NativeDatabase(databaseFile),
      );

      addTearDown(database.close);

      // أول query يفتح قاعدة v4 ويشغل MigrationStrategy إلى v6.
      final List<SyncOperation> operations = await database
          .select(database.syncOperations)
          .get();

      final List<OrderRecord> orders = await database
          .select(database.orderRecords)
          .get();

      expect(database.schemaVersion, 6);
      expect(operations, hasLength(1));
      expect(orders, hasLength(1));

      final SyncOperation operation = operations.single;

      expect(operation.id, 'order:create:legacy-order');
      expect(operation.entityType, 'order');
      expect(operation.entityId, 'legacy-order');
      expect(operation.operation, 'create');
      expect(operation.payloadJson, '{"legacy":true}');
      expect(operation.attempts, 2);
      expect(operation.lastError, 'temporary failure');
      expect(operation.nextAttemptAt, isNull);

      // الصف التاريخي يأخذ default الجديد بدل أن يضيع أو يتوقف عن القراءة.
      expect(operation.status, SyncOperationStatuses.pending);

      final OrderRecord order = orders.single;

      expect(order.id, 'legacy-order');
      expect(order.status, 'delivered');
      expect(order.notes, 'legacy order');
      expect(order.aggregateStatus, 'pending_responses');
    });
  });
}

/// يبني فقط الجزء الذي نحتاجه من schema v4 كما كان قبل إضافة status.
///
/// الاختبار لا يعيد إنشاء schema v5 يدويًا؛ هدفه أن تكون MigrationStrategy
/// الفعلية في AppDatabase هي المسؤولة عن تحويل الجدول القديم.
void _createLegacyV4Database(File file) {
  final sqlite.Database database = sqlite.sqlite3.open(file.path);

  try {
    database.execute('''
      CREATE TABLE order_records (
        id TEXT NOT NULL PRIMARY KEY,
        status TEXT NOT NULL DEFAULT 'pending',
        notes TEXT NOT NULL DEFAULT '',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      );
    ''');

    database.execute(
      '''
      INSERT INTO order_records (
        id,
        status,
        notes,
        created_at,
        updated_at
      ) VALUES (?, ?, ?, ?, ?);
      ''',
      <Object?>[
        'legacy-order',
        'delivered',
        'legacy order',
        1724800000,
        1724800000,
      ],
    );

    database.execute('''
      CREATE TABLE sync_operations (
        id TEXT NOT NULL PRIMARY KEY,
        entity_type TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        operation TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        attempts INTEGER NOT NULL DEFAULT 0,
        last_error TEXT NULL,
        next_attempt_at INTEGER NULL,
        created_at INTEGER NOT NULL
      );
    ''');

    database.execute(
      '''
      INSERT INTO sync_operations (
        id,
        entity_type,
        entity_id,
        operation,
        payload_json,
        attempts,
        last_error,
        next_attempt_at,
        created_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
      ''',
      <Object?>[
        'order:create:legacy-order',
        'order',
        'legacy-order',
        'create',
        '{"legacy":true}',
        2,
        'temporary failure',
        null,
        1724800000,
      ],
    );

    // Drift يقرأ هذه القيمة ليقرر أن onUpgrade يجب أن ينفذ v4 → v5.
    database.execute('PRAGMA user_version = 4;');
  } finally {
    database.close();
  }
}

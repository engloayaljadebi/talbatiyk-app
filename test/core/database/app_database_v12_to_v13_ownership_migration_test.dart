import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';

void main() {
  test(
    'v12 to v13 preserves legacy order and outbox without inventing owner',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'talbatiyk-ownership-migration-',
      );

      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final file = File(
        '${directory.path}${Platform.pathSeparator}legacy.sqlite',
      );

      final initial = AppDatabase.forTesting(NativeDatabase(file));

      final createdAt = DateTime.utc(2026, 10, 12);

      await initial
          .into(initial.orderRecords)
          .insert(
            OrderRecordsCompanion.insert(
              id: 'legacy-order-A',
              notes: const Value('Preserve this offline order'),
              createdAt: createdAt,
              updatedAt: createdAt,
            ),
          );

      await initial
          .into(initial.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              id: 'order:create:legacy-order-A',
              entityType: 'order',
              entityId: 'legacy-order-A',
              operation: 'create',
              payloadJson: '{"legacy":true}',
              createdAt: createdAt,
            ),
          );

      await initial.close();

      // Reconstruct the exact schema delta between v12 and v13:
      // v12 had neither owner_user_id column.
      final raw = sqlite.sqlite3.open(file.path);

      try {
        raw.execute('ALTER TABLE order_records DROP COLUMN owner_user_id;');

        raw.execute('ALTER TABLE sync_operations DROP COLUMN owner_user_id;');

        raw.execute('PRAGMA user_version = 12;');

        final version = raw.select('PRAGMA user_version;');

        expect(version.single.values.single, 12);

        for (final table in ['order_records', 'sync_operations']) {
          final columns = raw.select("PRAGMA table_info('$table');");

          expect(
            columns.any((column) => column['name'] == 'owner_user_id'),
            isFalse,
          );
        }
      } finally {
        raw.close();
      }

      // Opening the persisted v12 database runs the real
      // production upgrade path to schema v13.
      final upgraded = AppDatabase.forTesting(NativeDatabase(file));

      addTearDown(upgraded.close);

      final orders = await upgraded.select(upgraded.orderRecords).get();

      final operations = await upgraded.select(upgraded.syncOperations).get();

      expect(upgraded.schemaVersion, 14);

      expect(orders, hasLength(1));
      expect(orders.single.id, 'legacy-order-A');
      expect(orders.single.notes, 'Preserve this offline order');

      expect(
        orders.single.ownerUserId,
        isNull,
        reason: 'Legacy ownership must never be guessed.',
      );

      expect(operations, hasLength(1));
      expect(operations.single.id, 'order:create:legacy-order-A');
      expect(operations.single.entityId, 'legacy-order-A');
      expect(operations.single.payloadJson, '{"legacy":true}');
      expect(
        operations.single.ownerUserId,
        isNull,
        reason: 'Legacy outbox must remain unassigned.',
      );

      for (final table in ['order_records', 'sync_operations']) {
        final columns = await upgraded
            .customSelect("PRAGMA table_info('$table');")
            .get();

        expect(
          columns.any((column) => column.data['name'] == 'owner_user_id'),
          isTrue,
        );
      }
    },
  );
}

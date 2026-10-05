import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'v11 to v12 preserves products and backfills server-backed versions',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'product-version-v11-v12-',
      );

      addTearDown(() async {
        if (await directory.exists()) {
          await directory.delete(recursive: true);
        }
      });

      final file = File(
        '${directory.path}${Platform.pathSeparator}database.sqlite',
      );

      final initial = AppDatabase.forTesting(NativeDatabase(file));
      final time = DateTime.utc(2026, 10, 4);

      await initial
          .into(initial.productRecords)
          .insert(
            ProductRecordsCompanion.insert(
              id: 'server-product',
              supplierId: 'supplier-1',
              supplierName: 'Supplier',
              name: 'Server Product',
              price: 100,
              syncStatus: Value(ProductSyncStatus.synced.name),
              serverVersion: const Value(9),
              createdAt: time,
              updatedAt: time,
            ),
          );

      await initial
          .into(initial.productRecords)
          .insert(
            ProductRecordsCompanion.insert(
              id: 'pending-create',
              supplierId: 'supplier-1',
              supplierName: 'Supplier',
              name: 'Pending Create',
              price: 200,
              syncStatus: Value(ProductSyncStatus.pendingCreate.name),
              createdAt: time,
              updatedAt: time,
            ),
          );

      await initial.close();

      final raw = sqlite.sqlite3.open(file.path);

      raw.execute('ALTER TABLE product_records DROP COLUMN server_version;');
      raw.execute('PRAGMA user_version = 11;');
      raw.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(upgraded.close);

      final rows = await upgraded.select(upgraded.productRecords).get();

      final serverProduct = rows.singleWhere(
        (row) => row.id == 'server-product',
      );

      final pendingCreate = rows.singleWhere(
        (row) => row.id == 'pending-create',
      );

      expect(upgraded.schemaVersion, 12);

      // Existing server-backed rows receive the backend rollout baseline.
      expect(serverProduct.serverVersion, 1);

      // A purely local create has never received a server concurrency token.
      expect(pendingCreate.serverVersion, null);

      final columns = await upgraded
          .customSelect("PRAGMA table_info('product_records');")
          .get();

      expect(
        columns.any((row) => row.data['name'] == 'server_version'),
        isTrue,
      );
    },
  );
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_discovery_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

void main() {
  test(
    'legitimate v10 preserves governorate data and adds publish-attempt table',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'product-v10-v11-',
      );

      addTearDown(() => directory.delete(recursive: true));

      final file = File(
        '${directory.path}${Platform.pathSeparator}test.sqlite',
      );

      final initial = AppDatabase.forTesting(NativeDatabase(file));

      final discovery = ProductsDiscoveryLocalDataSource(initial);

      await discovery.replaceCachedProducts(const [
        ProductModel(
          id: 'existing-product',
          supplierId: 'supplier-1',
          supplierName: 'Supplier',
          supplierGovernorate: 'صنعاء',
          name: 'Existing product',
          price: 1000,
          imageUrl: '',
          category: 'Electronics',
          brand: 'Test',
          isAvailable: true,
          quantity: 5,
        ),
      ]);

      await initial.close();

      final raw = sqlite.sqlite3.open(file.path);

      raw.execute('DROP TABLE product_publish_attempt_records;');

      raw.execute('PRAGMA user_version = 10;');

      raw.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));

      addTearDown(upgraded.close);

      expect(upgraded.schemaVersion, 11);

      final attemptTables = await upgraded
          .customSelect(
            "SELECT name FROM sqlite_master "
            "WHERE type = 'table' "
            "AND name = 'product_publish_attempt_records';",
          )
          .get();

      expect(attemptTables, hasLength(1));

      final cached = await ProductsDiscoveryLocalDataSource(
        upgraded,
      ).getCachedProducts();

      expect(cached, hasLength(1));

      expect(cached.single.supplierGovernorate, 'صنعاء');
    },
  );

  test(
    'transitional development v10 repairs missing governorate without recreating publish-attempt table',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'product-transitional-v10-v11-',
      );

      addTearDown(() => directory.delete(recursive: true));

      final file = File(
        '${directory.path}${Platform.pathSeparator}test.sqlite',
      );

      final initial = AppDatabase.forTesting(NativeDatabase(file));

      await initial
          .into(initial.productPublishAttemptRecords)
          .insert(
            ProductPublishAttemptRecordsCompanion.insert(
              idempotencyKey: '11111111-1111-4111-8111-111111111111',
              clientProductId: '22222222-2222-4222-8222-222222222222',
              supplierId: '33333333-3333-4333-8333-333333333333',
              supplierName: 'Supplier',
              name: 'Preserve Attempt',
              category: 'Electronics',
              price: 1000,
              quantity: 1,
              isAvailable: true,
              createdAt: DateTime.utc(2026, 9, 26),
              updatedAt: DateTime.utc(2026, 9, 26),
            ),
          );

      await initial.close();

      final raw = sqlite.sqlite3.open(file.path);

      final columns = raw.select(
        "PRAGMA table_info('product_discovery_records');",
      );

      final hasGovernorate = columns.any(
        (row) => row['name'] == 'supplier_governorate',
      );

      if (hasGovernorate) {
        raw.execute(
          'ALTER TABLE product_discovery_records '
          'DROP COLUMN supplier_governorate;',
        );
      }

      /*
       * Simulates the temporary development state that reported v10 while
       * already containing ProductPublishAttemptRecords.
       */
      raw.execute('PRAGMA user_version = 10;');

      raw.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));

      addTearDown(upgraded.close);

      expect(upgraded.schemaVersion, 11);

      final repairedColumns = await upgraded
          .customSelect("PRAGMA table_info('product_discovery_records');")
          .get();

      expect(
        repairedColumns.any(
          (row) => row.data['name'] == 'supplier_governorate',
        ),
        isTrue,
      );

      final attempts = await upgraded
          .select(upgraded.productPublishAttemptRecords)
          .get();

      expect(attempts, hasLength(1));

      expect(
        attempts.single.idempotencyKey,
        '11111111-1111-4111-8111-111111111111',
      );
    },
  );
}

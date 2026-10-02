import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_discovery_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'v9 upgrade preserves discovery products and adds supplier governorate',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'product-governorate-v10-',
      );

      addTearDown(() => directory.delete(recursive: true));

      final file = File(
        '${directory.path}${Platform.pathSeparator}test.sqlite',
      );

      final initial = AppDatabase.forTesting(NativeDatabase(file));

      final initialLocal = ProductsDiscoveryLocalDataSource(initial);

      await initialLocal.replaceCachedProducts([
        ProductModel(
          id: 'existing-product',
          supplierId: 'supplier-1',
          supplierName: 'Supplier One',
          name: 'Existing product',
          price: 1000,
          imageUrl: '',
          category: 'Electronics',
          brand: 'Test',
          isAvailable: true,
          description: '',
          colors: const [],
          quantity: 5,
          discount: 0,
          rating: 0,
          syncStatus: ProductSyncStatus.synced,
        ),
      ]);

      await initial.close();

      final raw = sqlite.sqlite3.open(file.path);

      final columns = raw.select(
        "PRAGMA table_info('product_discovery_records')",
      );

      final hasGovernorate = columns.any(
        (row) => row['name'] == 'supplier_governorate',
      );

      // supplier_governorate is the historical v10 addition.
      // Remove it to simulate an installed v9 database.
      if (hasGovernorate) {
        raw.execute(
          'ALTER TABLE product_discovery_records '
          'DROP COLUMN supplier_governorate',
        );
      }

      raw.execute('PRAGMA user_version = 9');
      raw.close();

      final upgraded = AppDatabase.forTesting(NativeDatabase(file));

      addTearDown(upgraded.close);

      expect(upgraded.schemaVersion, 11);

      final upgradedColumns = await upgraded
          .customSelect("PRAGMA table_info('product_discovery_records')")
          .get();

      expect(
        upgradedColumns.any(
          (row) => row.data['name'] == 'supplier_governorate',
        ),
        isTrue,
      );

      final local = ProductsDiscoveryLocalDataSource(upgraded);

      final cached = await local.getCachedProducts();

      expect(cached, hasLength(1));
      expect(cached.single.id, 'existing-product');
      expect(cached.single.name, 'Existing product');
    },
  );
}

import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_discovery_local_datasource.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/datasources/products_offline_first_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

void main() {
  test(
    'discovery cache survives database close and reopen while remote is offline',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'talbatiyk-discovery-persistence-',
      );

      final databaseFile = File(
        '${tempDirectory.path}${Platform.pathSeparator}talbatiyk.sqlite',
      );

      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final firstDatabase = AppDatabase.forTesting(
        NativeDatabase(databaseFile),
      );

      final firstLocal = ProductsDiscoveryLocalDataSource(firstDatabase);

      final onlineSource = ProductsOfflineFirstDataSource(
        localDataSource: firstLocal,
        remoteDataSource: const _RemoteProductsDataSource(
          products: [
            ProductModel(
              id: 'persisted-product-1',
              supplierId: 'supplier-1',
              supplierName: 'Persistent Supplier',
              name: 'Persistent Product',
              price: 4500,
              imageUrl: 'https://example.test/product.jpg',
              category: 'Chargers',
              brand: 'Talbatiyk',
              isAvailable: true,
              description: 'Product persisted across database reopen.',
              colors: ['Black'],
              quantity: 9,
              rating: 4.8,
            ),
          ],
        ),
      );

      final onlineProducts = await onlineSource.getProducts();

      expect(onlineProducts, hasLength(1));
      expect(onlineProducts.single.id, 'persisted-product-1');

      await firstDatabase.close();

      // Opening a new AppDatabase instance over the same SQLite file models
      // a real application process reopening its persisted local catalog.
      final reopenedDatabase = AppDatabase.forTesting(
        NativeDatabase(databaseFile),
      );

      addTearDown(reopenedDatabase.close);

      final reopenedLocal = ProductsDiscoveryLocalDataSource(reopenedDatabase);

      final offlineSource = ProductsOfflineFirstDataSource(
        localDataSource: reopenedLocal,
        remoteDataSource: const _FailingProductsDataSource(),
      );

      final offlineProducts = await offlineSource.getProducts();

      expect(offlineProducts, hasLength(1));

      final product = offlineProducts.single;

      expect(product.id, 'persisted-product-1');
      expect(product.name, 'Persistent Product');
      expect(product.supplierId, 'supplier-1');
      expect(product.supplierName, 'Persistent Supplier');
      expect(product.price, 4500);
      expect(product.quantity, 9);
      expect(product.rating, 4.8);
    },
  );
}

final class _RemoteProductsDataSource implements ProductsDataSource {
  const _RemoteProductsDataSource({required this.products});

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async {
    return List<ProductModel>.unmodifiable(products);
  }
}

final class _FailingProductsDataSource implements ProductsDataSource {
  const _FailingProductsDataSource();

  @override
  Future<List<ProductModel>> getProducts() {
    throw StateError('network unavailable');
  }
}

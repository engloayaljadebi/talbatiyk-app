import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbatiyk/features/auth/presentation/providers/account_session_fence_provider.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';

void main() {
  test(
    'local data source can be replaced without changing the use case',
    () async {
      final container = ProviderContainer(
        overrides: [
          productsDataSourceProvider.overrideWithValue(
            const _FakeProductsDataSource([
              ProductModel(
                id: 'api-product',
                name: 'API product',
                price: 1000,
                imageUrl: '',
                category: 'Tests',
                brand: 'Talbatiyk',
                isAvailable: true,
              ),
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final products = await container
          .read(productsUseCaseProvider)
          .getProducts();

      expect(products, hasLength(1));
      expect(products.single.id, 'api-product');
    },
  );

  test(
    'discovery rejects stale product cache and responses after a session switch',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      var session = _session('market-a');
      final remoteDataSource = _ControllableProductsDataSource(
        products: const [
          ProductModel(
            id: 'server-product-1',
            supplierId: 'supplier-1',
            supplierName: 'Supplier One',
            name: 'Server product',
            price: 2500,
            imageUrl: 'https://example.test/product.jpg',
            category: 'Electronics',
            brand: 'Test Brand',
            isAvailable: true,
            description: 'Server discovery product',
            quantity: 12,
            rating: 4.5,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountSessionFenceProvider.overrideWithValue(
            AccountSessionFence(() => session),
          ),
          productDiscoveryRemoteDataSourceProvider.overrideWithValue(
            remoteDataSource,
          ),
        ],
      );

      addTearDown(database.close);
      addTearDown(container.dispose);

      final onlineProducts = await container
          .read(productDiscoveryUseCaseProvider)
          .getProducts();

      expect(onlineProducts, hasLength(1));
      expect(onlineProducts.single.id, 'server-product-1');

      final discovery = container.read(productDiscoveryLocalDataSourceProvider);
      expect(await discovery.getCachedProducts(), isEmpty);

      await discovery.replaceCachedProducts(await remoteDataSource.getProducts());
      session = _session('market-b');
      remoteDataSource.error = StateError('network unavailable');

      await expectLater(
        container.read(productDiscoveryUseCaseProvider).getProducts(),
        throwsStateError,
      );

      remoteDataSource.error = null;
      final pending = Completer<List<ProductModel>>();
      remoteDataSource.pending = pending;
      final load = container.read(productDiscoveryDataSourceProvider).getProducts();
      session = _session('market-c');
      pending.complete([]);
      await expectLater(load, throwsStateError);

      expect(await database.select(database.productRecords).get(), isEmpty);
      expect(await database.select(database.syncOperations).get(), isEmpty);
    },
  );

  test(
    'discovery data source remains replaceable for isolated UI tests',
    () async {
      final container = ProviderContainer(
        overrides: [
          productDiscoveryDataSourceProvider.overrideWithValue(
            const _FakeProductsDataSource([
              ProductModel(
                id: 'isolated-discovery-product',
                supplierId: 'supplier-2',
                supplierName: 'Supplier Two',
                name: 'Isolated discovery product',
                price: 3000,
                imageUrl: '',
                category: 'Tests',
                brand: 'Talbatiyk',
                isAvailable: true,
              ),
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      final products = await container
          .read(productDiscoveryUseCaseProvider)
          .getProducts();

      expect(products, hasLength(1));
      expect(products.single.id, 'isolated-discovery-product');
    },
  );
}

class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async {
    return List<ProductModel>.unmodifiable(products);
  }
}

class _ControllableProductsDataSource implements ProductsDataSource {
  _ControllableProductsDataSource({required List<ProductModel> products})
    : _products = List<ProductModel>.of(products);

  final List<ProductModel> _products;

  Object? error;
  Completer<List<ProductModel>>? pending;

  @override
  Future<List<ProductModel>> getProducts() async {
    final currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    final request = pending;
    if (request != null) return request.future;

    return List<ProductModel>.unmodifiable(_products);
  }
}

AuthSessionEntity _session(String id) => AuthSessionEntity(
  user: AuthUserEntity(
    id: id,
    username: id,
    displayName: id,
    status: 'active',
    lastLoginAt: null,
    contacts: const [],
  ),
);

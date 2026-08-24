import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
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
    'discovery persists remote snapshot in dedicated cache and reuses it offline',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

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

      final cachedProducts = await container
          .read(productDiscoveryLocalDataSourceProvider)
          .getCachedProducts();

      expect(cachedProducts, hasLength(1));
      expect(cachedProducts.single.id, 'server-product-1');

      final discoveryRecords = await database
          .select(database.productDiscoveryRecords)
          .get();

      final managementRecords = await database
          .select(database.productRecords)
          .get();

      final outboxOperations = await database
          .select(database.syncOperations)
          .get();

      expect(discoveryRecords, hasLength(1));
      expect(managementRecords, isEmpty);
      expect(outboxOperations, isEmpty);

      remoteDataSource.error = StateError('network unavailable');

      final offlineProducts = await container
          .read(productDiscoveryUseCaseProvider)
          .getProducts();

      expect(offlineProducts, hasLength(1));
      expect(offlineProducts.single.id, 'server-product-1');
      expect(offlineProducts.single.name, 'Server product');
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

  @override
  Future<List<ProductModel>> getProducts() async {
    final currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    return List<ProductModel>.unmodifiable(_products);
  }
}

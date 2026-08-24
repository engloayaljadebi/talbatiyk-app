import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/datasources/products_offline_first_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

void main() {
  group('ProductsOfflineFirstDataSource', () {
    test(
      'refreshes from remote, stores the snapshot, and returns cached data',
      () async {
        final cache = _FakeProductsCacheDataSource([
          _product(id: 'cached-product', name: 'Old cached product'),
        ]);

        final remote = _FakeProductsRemoteDataSource.success([
          _product(id: 'server-product', name: 'Fresh server product'),
        ]);

        final dataSource = ProductsOfflineFirstDataSource(
          localDataSource: cache,
          remoteDataSource: remote,
        );

        final products = await dataSource.getProducts();

        expect(products, hasLength(1));
        expect(products.single.id, 'server-product');
        expect(products.single.name, 'Fresh server product');

        expect(cache.replaceCalls, 1);
        expect(cache.cachedProducts.single.id, 'server-product');
      },
    );

    test('returns existing cache when the remote request fails', () async {
      final cache = _FakeProductsCacheDataSource([
        _product(id: 'cached-product', name: 'Available offline'),
      ]);

      final dataSource = ProductsOfflineFirstDataSource(
        localDataSource: cache,
        remoteDataSource: _FakeProductsRemoteDataSource.failure(
          StateError('network unavailable'),
        ),
      );

      final products = await dataSource.getProducts();

      expect(products, hasLength(1));
      expect(products.single.id, 'cached-product');
      expect(products.single.name, 'Available offline');
      expect(cache.replaceCalls, 0);
    });

    test('rethrows the remote failure when no local cache exists', () async {
      final dataSource = ProductsOfflineFirstDataSource(
        localDataSource: _FakeProductsCacheDataSource(const []),
        remoteDataSource: _FakeProductsRemoteDataSource.failure(
          StateError('network unavailable'),
        ),
      );

      await expectLater(dataSource.getProducts(), throwsA(isA<StateError>()));
    });

    test(
      'a successful empty server snapshot clears stale discovery cache',
      () async {
        final cache = _FakeProductsCacheDataSource([
          _product(id: 'stale-product', name: 'Stale product'),
        ]);

        final dataSource = ProductsOfflineFirstDataSource(
          localDataSource: cache,
          remoteDataSource: _FakeProductsRemoteDataSource.success(const []),
        );

        final products = await dataSource.getProducts();

        expect(products, isEmpty);
        expect(cache.cachedProducts, isEmpty);
        expect(cache.replaceCalls, 1);
      },
    );
  });
}

class _FakeProductsCacheDataSource implements ProductsCacheDataSource {
  _FakeProductsCacheDataSource(List<ProductModel> products)
    : cachedProducts = List<ProductModel>.of(products);

  List<ProductModel> cachedProducts;
  int replaceCalls = 0;

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    return List<ProductModel>.unmodifiable(cachedProducts);
  }

  @override
  Future<void> replaceCachedProducts(List<ProductModel> products) async {
    replaceCalls += 1;
    cachedProducts = List<ProductModel>.of(products);
  }
}

class _FakeProductsRemoteDataSource implements ProductsDataSource {
  _FakeProductsRemoteDataSource.success(this._products) : _error = null;

  _FakeProductsRemoteDataSource.failure(Object error)
    : _products = null,
      _error = error;

  final List<ProductModel>? _products;
  final Object? _error;

  @override
  Future<List<ProductModel>> getProducts() async {
    final error = _error;

    if (error != null) {
      throw error;
    }

    return List<ProductModel>.unmodifiable(_products!);
  }
}

ProductModel _product({required String id, required String name}) {
  return ProductModel(
    id: id,
    supplierId: 'supplier-1',
    supplierName: 'Supplier One',
    name: name,
    price: 1000,
    imageUrl: '',
    category: 'Electronics',
    brand: 'Test Brand',
    isAvailable: true,
  );
}

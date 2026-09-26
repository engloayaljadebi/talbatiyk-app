import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/mappers/products_mapper.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/data/repositories/products_repository_impl.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  final repository = ProductsRepositoryImpl(
    _FakeProductsDataSource(const [
      ProductModel(
        id: 'product-1',
        name: 'شاحن سريع',
        price: 4500,
        imageUrl: '',
        category: 'شواحن',
        brand: 'Samsung',
        isAvailable: true,
        description: 'ضمان سنة',
      ),
      ProductModel(
        id: 'product-2',
        name: 'سماعة',
        price: 15000,
        imageUrl: '',
        category: 'سماعات',
        brand: 'Apple',
        isAvailable: false,
      ),
    ]),
  );

  group('ProductsRepositoryImpl', () {
    test('maps data models to domain entities', () async {
      final products = await repository.getProducts();

      expect(products, hasLength(2));
      expect(products.first.name, 'شاحن سريع');
      expect(products.first.price, 4500);
    });

    test('searches across product fields', () async {
      final byBrand = await repository.searchProducts('apple');
      final byDescription = await repository.searchProducts('ضمان');

      expect(byBrand.single.id, 'product-2');
      expect(byDescription.single.id, 'product-1');
    });

    test(
      'filters products without depending on the data source type',
      () async {
        final products = await repository.filterProducts(
          category: 'شواحن',
          minPrice: 4000,
          maxPrice: 5000,
          available: true,
        );

        expect(products.single.id, 'product-1');
      },
    );
  });

  group('Product publishing reconciliation', () {
    test(
      'stores the canonical server product locally after remote publishing',
      () async {
        const clientProduct = ProductModel(
          id: 'temporary-client-id',
          supplierId: 'supplier-1',
          supplierName: 'المورد',
          name: 'منتج جديد',
          price: 1500,
          imageUrl: '',
          category: 'إلكترونيات',
          brand: 'Talbatiyk',
          isAvailable: true,
          quantity: 4,
        );

        const serverProduct = ProductModel(
          id: 'server-product-id',
          supplierId: 'supplier-1',
          supplierName: 'المورد',
          name: 'منتج جديد',
          price: 1500,
          imageUrl: 'https://example.test/product.jpg',
          category: 'إلكترونيات',
          brand: 'Talbatiyk',
          isAvailable: true,
          quantity: 4,
          syncStatus: ProductSyncStatus.synced,
        );

        final local = _FakeSyncedStoreDataSource();
        final remote = _FakePublishingDataSource(serverProduct);

        final publishingRepository = ProductsRepositoryImpl(
          local,
          createDataSource: remote,
        );

        final created = await publishingRepository.createProduct(
          ProductsMapper.toEntity(clientProduct),
        );

        expect(remote.receivedProduct?.id, clientProduct.id);
        expect(local.upsertCalls, 1);

        expect(local.syncedProduct?.id, serverProduct.id);
        expect(local.syncedProduct?.syncStatus, ProductSyncStatus.synced);

        expect(created.id, serverProduct.id);
        expect(created.id, isNot(clientProduct.id));
      },
    );

    test(
      'keeps remote publish successful when local reconciliation fails',
      () async {
        const clientProduct = ProductModel(
          id: 'temporary-client-id',
          supplierId: 'supplier-1',
          supplierName: 'المورد',
          name: 'منتج جديد',
          price: 1500,
          imageUrl: '',
          category: 'إلكترونيات',
          brand: 'Talbatiyk',
          isAvailable: true,
          quantity: 4,
        );

        const serverProduct = ProductModel(
          id: 'server-product-id',
          supplierId: 'supplier-1',
          supplierName: 'المورد',
          name: 'منتج جديد',
          price: 1500,
          imageUrl: 'https://example.test/product.jpg',
          category: 'إلكترونيات',
          brand: 'Talbatiyk',
          isAvailable: true,
          quantity: 4,
          syncStatus: ProductSyncStatus.synced,
        );

        final local = _FakeSyncedStoreDataSource(failOnUpsert: true);

        final remote = _FakePublishingDataSource(serverProduct);

        final publishingRepository = ProductsRepositoryImpl(
          local,
          createDataSource: remote,
        );

        final created = await publishingRepository.createProduct(
          ProductsMapper.toEntity(clientProduct),
        );

        /*
         * Laravel هو الذي نجح في الإنشاء.
         * خطأ Drift اللاحق لا يجب أن يجعل المستخدم يعيد POST.
         */
        expect(created.id, serverProduct.id);
        expect(remote.createCalls, 1);
        expect(local.upsertCalls, 1);
      },
    );
  });
}

class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async => products;
}

final class _FakePublishingDataSource implements ProductsCreateDataSource {
  _FakePublishingDataSource(this.serverProduct);

  final ProductModel serverProduct;

  ProductModel? receivedProduct;
  int createCalls = 0;

  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    createCalls += 1;
    receivedProduct = product;
    return serverProduct;
  }
}

final class _FakeSyncedStoreDataSource
    implements ProductsDataSource, ProductsSyncedStoreDataSource {
  _FakeSyncedStoreDataSource({this.failOnUpsert = false});

  final bool failOnUpsert;

  ProductModel? syncedProduct;
  int upsertCalls = 0;

  @override
  Future<List<ProductModel>> getProducts() async => const [];

  @override
  Future<ProductModel> upsertSyncedProduct(ProductModel product) async {
    upsertCalls += 1;

    if (failOnUpsert) {
      throw StateError('local reconciliation failed');
    }

    syncedProduct = product;
    return product;
  }
}

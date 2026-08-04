import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/data/repositories/products_repository_impl.dart';

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

    test('filters products without depending on the data source type', () async {
      final products = await repository.filterProducts(
        category: 'شواحن',
        minPrice: 4000,
        maxPrice: 5000,
        available: true,
      );

      expect(products.single.id, 'product-1');
    });
  });
}

class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async => products;
}

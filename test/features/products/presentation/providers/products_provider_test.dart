import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';

void main() {
  test('data source can be replaced without changing the use case', () async {
    final container = ProviderContainer(
      overrides: [
        productsDataSourceProvider.overrideWithValue(
          const _FakeProductsDataSource([
            ProductModel(
              id: 'api-product',
              name: 'منتج من API',
              price: 1000,
              imageUrl: '',
              category: 'اختبار',
              brand: 'طلبيتك',
              isAvailable: true,
            ),
          ]),
        ),
      ],
    );
    addTearDown(container.dispose);

    final products = await container.read(productsUseCaseProvider).getProducts();

    expect(products.single.id, 'api-product');
  });
}

class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async => products;
}

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/data/repositories/products_repository_impl.dart';
import 'package:talbatiyk/features/products/domain/usecases/products_usecase.dart';
import 'package:talbatiyk/features/products/presentation/controllers/products_controller.dart';
import 'package:talbatiyk/features/products/presentation/state/products_state.dart';

void main() {
  late ProductsController controller;

  setUp(() {
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

    controller = ProductsController(
      ProductsUseCase(repository),
      autoLoad: false,
    );
  });

  tearDown(() => controller.dispose());

  test('loads products through the injected use case', () async {
    await controller.loadProducts();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.products, hasLength(2));
    expect(controller.categories, ['سماعات', 'شواحن']);
    expect(controller.brands, ['Apple', 'Samsung']);
  });

  test('applies search and availability filters to loaded products', () async {
    await controller.loadProducts();

    controller.search('شاحن');
    expect(controller.state.products.single.id, 'product-1');

    controller.search('');
    controller.applyFilters(
      category: '',
      brand: '',
      availability: ProductAvailabilityFilter.unavailable,
      minPrice: controller.minimumPrice,
      maxPrice: controller.maximumPrice,
    );

    expect(controller.state.products.single.id, 'product-2');
  });
}

class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async => products;
}

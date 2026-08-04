import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_datasource.dart';
import '../mappers/products_mapper.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this.dataSource);

  final ProductsDataSource dataSource;

  @override
  Future<List<ProductEntity>> getProducts() async {
    final models = await dataSource.getProducts();

    return List<ProductEntity>.unmodifiable(
      models.map(ProductsMapper.toEntity),
    );
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final products = await getProducts();
    final normalizedQuery = query.trim().toLowerCase();

    return products.where((item) {
      return item.name.toLowerCase().contains(normalizedQuery) ||
          item.brand.toLowerCase().contains(normalizedQuery) ||
          item.category.toLowerCase().contains(normalizedQuery) ||
          item.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  Future<List<ProductEntity>> filterProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
  }) async {
    var products = await getProducts();

    if (category != null && category.isNotEmpty) {
      products = products.where((e) => e.category == category).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      products = products.where((e) => e.brand == brand).toList();
    }

    if (minPrice != null) {
      products = products.where((e) => e.price >= minPrice).toList();
    }

    if (maxPrice != null) {
      products = products.where((e) => e.price <= maxPrice).toList();
    }

    if (available != null) {
      products = products.where((e) => e.isAvailable == available).toList();
    }

    return products;
  }
}

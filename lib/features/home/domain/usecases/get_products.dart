import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/products_local_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  ProductRepositoryImpl(this.localDataSource);

  final ProductsLocalDataSource localDataSource;

  @override
  Future<List<Product>> getProducts() async {
    return localDataSource.getProducts();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    final products = localDataSource.getProducts();

    return products
        .where(
          (product) => product.name.toLowerCase().contains(query.toLowerCase()),
        )
        .toList();
  }

  @override
  Future<List<Product>> filterProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
  }) async {
    var products = localDataSource.getProducts();

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

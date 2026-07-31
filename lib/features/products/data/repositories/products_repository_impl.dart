import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/local/products_local_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this.local);

  final ProductsLocalDataSource local;

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await local.getProducts();
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final products = await local.getProducts();

    return products.where((item) {
      return item.name.toLowerCase().contains(query.toLowerCase());
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
    var products = await local.getProducts();

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

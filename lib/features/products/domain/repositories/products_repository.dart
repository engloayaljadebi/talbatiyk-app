import '../entities/products_entity.dart';

abstract class ProductsRepository {
  Future<List<ProductEntity>> getProducts();

  Future<List<ProductEntity>> searchProducts(String query);

  Future<List<ProductEntity>> filterProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
  });
}

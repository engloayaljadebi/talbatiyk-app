import '../entities/products_entity.dart';
import '../repositories/products_repository.dart';

class ProductsUseCase {
  ProductsUseCase(this.repository);

  final ProductsRepository repository;

  Future<List<ProductEntity>> getProducts() {
    return repository.getProducts();
  }

  Future<List<ProductEntity>> search(String query) {
    return repository.searchProducts(query);
  }

  Future<List<ProductEntity>> filter({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
  }) {
    return repository.filterProducts(
      category: category,
      brand: brand,
      minPrice: minPrice,
      maxPrice: maxPrice,
      available: available,
    );
  }
}

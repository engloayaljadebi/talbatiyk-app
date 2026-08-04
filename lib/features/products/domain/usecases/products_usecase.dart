import '../entities/products_entity.dart';
import '../repositories/products_repository.dart';

/// يحتوي على عمليات المنتجات وقواعد التحقق الأساسية.
class ProductsUseCase {
  ProductsUseCase(this.repository);

  final ProductsRepository repository;

  /// يجلب المنتجات من Repository.
  Future<List<ProductEntity>> getProducts() {
    return repository.getProducts();
  }

  /// يتحقق من المنتج ثم يحفظه محليًا ويجهزه للمزامنة.
  Future<ProductEntity> createProduct(ProductEntity product) async {
    if (product.id.trim().isEmpty) {
      throw ArgumentError('معرف المنتج مطلوب.');
    }

    if (product.supplierId.trim().isEmpty) {
      throw ArgumentError('معرف المورد مطلوب.');
    }

    if (product.supplierName.trim().isEmpty) {
      throw ArgumentError('اسم المورد مطلوب.');
    }

    if (product.name.trim().isEmpty) {
      throw ArgumentError('اسم المنتج مطلوب.');
    }

    if (product.price <= 0) {
      throw ArgumentError('يجب أن يكون السعر أكبر من صفر.');
    }

    if (product.quantity < 0) {
      throw ArgumentError('لا يمكن أن تكون الكمية أقل من صفر.');
    }

    return repository.createProduct(product);
  }

  /// يبحث في المنتجات باستخدام النص المدخل.
  Future<List<ProductEntity>> search(String query) {
    return repository.searchProducts(query);
  }

  /// يفلتر المنتجات حسب الفئة والشركة والسعر والتوفر.
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

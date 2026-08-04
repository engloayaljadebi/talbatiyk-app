import '../entities/products_entity.dart';

/// العقد الذي تستخدمه طبقة الأعمال للتعامل مع المنتجات.
///
/// الواجهة لا تعرف هل البيانات محفوظة محليًا أو موجودة في السحابة.
abstract class ProductsRepository {
  /// يعيد جميع المنتجات المتاحة محليًا.
  Future<List<ProductEntity>> getProducts();

  /// يحفظ منتجًا جديدًا محليًا ويجهزه للمزامنة.
  Future<ProductEntity> createProduct(ProductEntity product);

  /// يبحث في المنتجات بالاسم أو الشركة أو الفئة أو الوصف.
  Future<List<ProductEntity>> searchProducts(String query);

  /// يفلتر المنتجات حسب الخيارات المحددة.
  Future<List<ProductEntity>> filterProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
  });
}

import '../models/products_model.dart';

/// عقد قراءة المنتجات.
///
/// يمكن تطبيقه بواسطة قاعدة البيانات المحلية أو API أو مصدر تجريبي.
abstract interface class ProductsDataSource {
  /// يعيد قائمة المنتجات المتاحة للعرض.
  Future<List<ProductModel>> getProducts();
}

/// عقد عمليات كتابة المنتجات.
///
/// فصل الكتابة عن القراءة يسمح لبعض المصادر بتنفيذ القراءة فقط،
/// بينما ينفذ المصدر المحلي والسحابي عمليات الإنشاء والتعديل والحذف.
abstract interface class ProductsWritableDataSource {
  /// يحفظ منتجًا جديدًا ويعيد النسخة التي تم حفظها.
  Future<ProductModel> createProduct(ProductModel product);

  /// يحدّث منتجًا موجودًا ويعيد النسخة المحدثة.
  ///
  /// عند عدم توفر الإنترنت، تُحفظ التغييرات محليًا وتنتظر المزامنة.
  Future<ProductModel> updateProduct(ProductModel product);

  /// يحذف المنتج محليًا ويسجل عملية حذفه للسحابة.
  ///
  /// سيكون الحذف منطقيًا أولًا حتى لا نفقد معرف المنتج قبل مزامنته.
  Future<void> deleteProduct(String productId);
}

import '../models/products_model.dart';

/// عقد قراءة المنتجات.
///
/// يمكن تطبيقه بواسطة قاعدة البيانات المحلية أو الـAPI أو مصدر تجريبي.
abstract interface class ProductsDataSource {
  Future<List<ProductModel>> getProducts();
}

/// عقد إضافة وتعديل المنتجات.
///
/// فصل الكتابة عن القراءة يسمح للاختبارات ومصادر العرض بتنفيذ القراءة فقط،
/// بينما المصدر المحلي والسحابي يستطيعان تنفيذ عمليات الحفظ.
abstract interface class ProductsWritableDataSource {
  /// يحفظ منتجًا جديدًا ويعيد النسخة التي تم حفظها.
  Future<ProductModel> createProduct(ProductModel product);
}

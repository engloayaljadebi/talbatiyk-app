import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_datasource.dart';
import '../mappers/products_mapper.dart';

/// تنفيذ المستودع الذي يعزل الواجهة وطبقة الأعمال عن مصادر البيانات.
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this.dataSource);

  final ProductsDataSource dataSource;

  /// يعيد مصدر البيانات القابل للكتابة بعد التأكد من دعمه للعمليات.
  ProductsWritableDataSource get _writableDataSource {
    final source = dataSource;

    if (source is! ProductsWritableDataSource) {
      throw UnsupportedError(
        'مصدر المنتجات الحالي لا يدعم إنشاء المنتجات أو تعديلها أو حذفها.',
      );
    }

    // أصبح التحويل آمنًا بعد التحقق السابق.
    return source as ProductsWritableDataSource;
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    final models = await dataSource.getProducts();

    return List<ProductEntity>.unmodifiable(
      models.map(ProductsMapper.toEntity),
    );
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    // نحول كيان المنتج إلى نموذج تفهمه طبقة البيانات.
    final model = ProductsMapper.fromEntity(product);

    // المصدر المحلي يحفظ المنتج ويضيف عملية الإنشاء إلى طابور المزامنة.
    final savedModel = await _writableDataSource.createProduct(model);

    // نعيد Entity حتى لا تتعامل الواجهة مع نماذج طبقة البيانات.
    return ProductsMapper.toEntity(savedModel);
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    // نحول المنتج المعدّل إلى نموذج بيانات.
    final model = ProductsMapper.fromEntity(product);

    // نحفظ التعديل محليًا ونسجل عملية المزامنة المناسبة.
    final updatedModel = await _writableDataSource.updateProduct(model);

    return ProductsMapper.toEntity(updatedModel);
  }

  @override
  Future<void> deleteProduct(String productId) {
    // ينفذ المصدر المحلي الحذف المنطقي أو النهائي حسب حالة المزامنة.
    return _writableDataSource.deleteProduct(productId);
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
      products = products.where((item) {
        return item.category == category;
      }).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      products = products.where((item) {
        return item.brand == brand;
      }).toList();
    }

    if (minPrice != null) {
      products = products.where((item) {
        return item.price >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      products = products.where((item) {
        return item.price <= maxPrice;
      }).toList();
    }

    if (available != null) {
      products = products.where((item) {
        return item.isAvailable == available;
      }).toList();
    }

    return products;
  }
}

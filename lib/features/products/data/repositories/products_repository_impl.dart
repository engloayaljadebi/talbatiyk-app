import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_datasource.dart';
import '../mappers/products_mapper.dart';

/// تنفيذ Repository الذي يعزل الواجهة عن مصادر البيانات.
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
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final source = dataSource;

    /// نتحقق أن مصدر البيانات الحالي يدعم عمليات الكتابة.
    if (source is! ProductsWritableDataSource) {
      throw UnsupportedError('مصدر المنتجات الحالي لا يدعم إضافة المنتجات.');
    }

    /// نحول Entity إلى Model قبل إرساله إلى طبقة البيانات.
    final model = ProductsMapper.fromEntity(product);

    /// بعد التحقق السابق أصبح التحويل آمنًا، ونستطيع استخدام دالة الكتابة.
    final writableSource = source as ProductsWritableDataSource;

    /// المصدر المحلي يحفظ المنتج ويضيفه إلى طابور المزامنة.
    final savedModel = await writableSource.createProduct(model);

    /// نعيد المنتج كـEntity حتى لا تتعامل الواجهة مع نماذج البيانات.
    return ProductsMapper.toEntity(savedModel);
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

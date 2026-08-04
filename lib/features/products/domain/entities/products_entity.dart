/// حالات مزامنة المنتج بين قاعدة البيانات المحلية والسحابة.
enum ProductSyncStatus {
  /// المنتج محفوظ محليًا ولم يُرفع إلى السحابة بعد.
  pendingCreate,

  /// المنتج عُدّل محليًا وينتظر إرسال التعديل.
  pendingUpdate,

  /// المنتج حُذف محليًا وينتظر حذف نسخته السحابية.
  pendingDelete,

  /// المنتج المحلي والسحابي متطابقان.
  synced,

  /// فشلت آخر محاولة مزامنة ويمكن إعادة المحاولة.
  failed,
}

/// كيان المنتج المستخدم داخل طبقة الأعمال والواجهة.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.isAvailable,
    this.supplierId = '',
    this.supplierName = '',
    this.description = '',
    this.colors = const [],
    this.quantity = 0,
    this.discount = 0,
    this.rating = 0,
    this.localImagePath,
    this.syncStatus = ProductSyncStatus.synced,
    this.syncError,
    this.createdAt,
    this.updatedAt,
  });

  /// معرف ثابت يُنشأ على الجهاز ويُستخدم محليًا وسحابيًا.
  final String id;

  /// معرف التاجر أو المورد الذي رفع المنتج.
  final String supplierId;

  /// اسم التاجر، ونحتفظ به محليًا للعمل دون إنترنت.
  final String supplierName;

  final String name;
  final double price;

  /// رابط الصورة السحابية أو صورة افتراضية موجودة في المشروع.
  final String imageUrl;

  /// مسار الصورة داخل جهاز المورد قبل رفعها إلى السحابة.
  final String? localImagePath;

  final String category;
  final String brand;
  final bool isAvailable;
  final String description;
  final List<String> colors;
  final int quantity;
  final double discount;
  final double rating;

  /// حالة مزامنة المنتج الحالية.
  final ProductSyncStatus syncStatus;

  /// رسالة آخر خطأ مزامنة، إن وُجد.
  final String? syncError;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// يحدد هل المنتج يحتاج إلى إرسال أو إعادة محاولة المزامنة.
  bool get needsSync => syncStatus != ProductSyncStatus.synced;

  /// يستخدم الصورة المحلية أولًا، ثم ينتقل إلى الصورة السحابية.
  String get displayImagePath {
    final localPath = localImagePath?.trim();

    if (localPath != null && localPath.isNotEmpty) {
      return localPath;
    }

    return imageUrl;
  }
}

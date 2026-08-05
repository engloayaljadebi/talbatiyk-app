import '../../domain/entities/products_entity.dart';

/// نموذج المنتج المستخدم في طبقة البيانات وقاعدة البيانات والـAPI.
class ProductModel {
  const ProductModel({
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

  /// المعرف نفسه يُستخدم محليًا وسحابيًا لمنع تكرار المنتج.
  final String id;

  /// بيانات المورد ضرورية لمعرفة مصدر المنتج داخل الطلبية.
  final String supplierId;
  final String supplierName;

  final String name;
  final double price;
  final String imageUrl;
  final String? localImagePath;
  final String category;
  final String brand;
  final bool isAvailable;
  final String description;
  final List<String> colors;
  final int quantity;
  final double discount;
  final double rating;

  /// تحدد هل المنتج متزامن أو ما زال ينتظر الرفع.
  final ProductSyncStatus syncStatus;

  /// تحتفظ بسبب فشل المزامنة لعرضه وإعادة المحاولة.
  final String? syncError;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// يحول النموذج إلى JSON لاستخدامه في طابور المزامنة والـAPI.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'localImagePath': localImagePath,
      'category': category,
      'brand': brand,
      'isAvailable': isAvailable,
      'description': description,
      'colors': colors,
      'quantity': quantity,
      'discount': discount,
      'rating': rating,
      'syncStatus': syncStatus.name,
      'syncError': syncError,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

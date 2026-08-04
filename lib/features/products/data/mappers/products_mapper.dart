import '../../domain/entities/products_entity.dart';
import '../dto/products_dto.dart';
import '../models/products_model.dart';

/// يحول بيانات المنتج بين DTO وModel وEntity دون فقدان المعلومات.
class ProductsMapper {
  /// يحول استجابة الـAPI إلى نموذج بيانات.
  ///
  /// بيانات المورد والمزامنة لها قيم افتراضية حاليًا، وسنضيفها إلى
  /// ProductDto عندما نربط الـAPI الحقيقي.
  static ProductModel toModel(ProductDto dto) {
    return ProductModel(
      id: dto.id,
      name: dto.name,
      price: dto.price,
      imageUrl: dto.imageUrl,
      category: dto.category,
      brand: dto.brand,
      isAvailable: dto.isAvailable,
      description: dto.description,
      colors: dto.colors,
      quantity: dto.quantity,
      discount: dto.discount,
      rating: dto.rating,
    );
  }

  /// يحول كيان الواجهة إلى نموذج يمكن حفظه محليًا أو إرساله للسحابة.
  static ProductModel fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      supplierId: entity.supplierId,
      supplierName: entity.supplierName,
      name: entity.name,
      price: entity.price,
      imageUrl: entity.imageUrl,
      localImagePath: entity.localImagePath,
      category: entity.category,
      brand: entity.brand,
      isAvailable: entity.isAvailable,
      description: entity.description,
      colors: entity.colors,
      quantity: entity.quantity,
      discount: entity.discount,
      rating: entity.rating,
      syncStatus: entity.syncStatus,
      syncError: entity.syncError,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// يحول نموذج البيانات إلى كيان تستخدمه الواجهة وطبقة الأعمال.
  static ProductEntity toEntity(ProductModel model) {
    return ProductEntity(
      id: model.id,
      supplierId: model.supplierId,
      supplierName: model.supplierName,
      name: model.name,
      price: model.price,
      imageUrl: model.imageUrl,
      localImagePath: model.localImagePath,
      category: model.category,
      brand: model.brand,
      isAvailable: model.isAvailable,
      description: model.description,
      colors: model.colors,
      quantity: model.quantity,
      discount: model.discount,
      rating: model.rating,
      syncStatus: model.syncStatus,
      syncError: model.syncError,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}

import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../domain/entities/products_entity.dart';
import '../dto/products_dto.dart';
import '../models/products_model.dart';

/// يحول بيانات المنتج بين DTO وModel وEntity دون فقدان المعلومات.
class ProductsMapper {
  /// Maps the generated OpenAPI ProductResource into the app data model.
  static ProductModel fromResource(ProductResource resource) {
    return ProductModel(
      id: resource.id,
      supplierId: resource.supplierId,
      supplierName: resource.supplierName,
      name: resource.name,
      price: resource.price.toDouble(),
      imageUrl: resource.imageUrl ?? '',
      category: resource.category,
      brand: resource.brand,
      isAvailable: resource.isAvailable,
      description: resource.description ?? '',
      colors: List<String>.unmodifiable(resource.colors),
      quantity: resource.quantity,
      discount: resource.discount.toDouble(),
      rating: resource.rating.toDouble(),
      createdAt: _parseDateTime(resource.createdAt),
      updatedAt: _parseDateTime(resource.updatedAt),
    );
  }

  static DateTime? _parseDateTime(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return DateTime.tryParse(normalized);
  }

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

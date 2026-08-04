import '../../domain/entities/products_entity.dart';
import '../dto/products_dto.dart';
import '../models/products_model.dart';

class ProductsMapper {
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

  static ProductEntity toEntity(ProductModel model) {
    return ProductEntity(
      id: model.id,
      name: model.name,
      price: model.price,
      imageUrl: model.imageUrl,
      category: model.category,
      brand: model.brand,
      isAvailable: model.isAvailable,
      description: model.description,
      colors: model.colors,
      quantity: model.quantity,
      discount: model.discount,
      rating: model.rating,
    );
  }
}

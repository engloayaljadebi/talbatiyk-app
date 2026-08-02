import '../../domain/entities/products_entity.dart';
import '../models/products_model.dart';

class ProductsMapper {
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

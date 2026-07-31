import '../../domain/entities/products_entity.dart';

class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.name,
    required super.price,
    required super.imageUrl,
    required super.category,
    required super.brand,
    required super.isAvailable,
    super.description,
    super.colors,
    super.quantity,
    super.discount,
    super.rating,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      name: json['name'],
      price: (json['price'] as num).toDouble(),
      imageUrl: json['imageUrl'],
      category: json['category'],
      brand: json['brand'],
      isAvailable: json['isAvailable'],
      description: json['description'] ?? '',
      colors: List<String>.from(json['colors'] ?? []),
      quantity: json['quantity'] ?? 0,
      discount: (json['discount'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'brand': brand,
      'isAvailable': isAvailable,
      'description': description,
      'colors': colors,
      'quantity': quantity,
      'discount': discount,
      'rating': rating,
    };
  }
}

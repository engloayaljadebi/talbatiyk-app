class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.isAvailable,
    this.description = '',
    this.colors = const [],
    this.quantity = 0,
    this.discount = 0,
    this.rating = 0,
  });

  final String id;
  final String name;
  final double price;
  final String imageUrl;
  final String category;
  final String brand;
  final bool isAvailable;
  final String description;
  final List<String> colors;
  final int quantity;
  final double discount;
  final double rating;

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

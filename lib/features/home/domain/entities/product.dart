class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.brand,
    required this.isAvailable,
    this.description,
    this.colors = const [],
    this.quantity = 0,
  });

  final String id;
  final String name;
  final double price;
  final String imageUrl;

  final String category;
  final String brand;

  final bool isAvailable;

  final String? description;

  final List<String> colors;

  final int quantity;
}

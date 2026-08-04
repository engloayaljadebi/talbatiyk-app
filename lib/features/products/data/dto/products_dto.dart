/// Raw product payload received from the API.
class ProductDto {
  const ProductDto({
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

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: _requiredString(json, const ['id']),
      name: _requiredString(json, const ['name']),
      price: _requiredDouble(json, const ['price']),
      imageUrl: _optionalString(json, const ['imageUrl', 'image_url']),
      category: _optionalString(json, const ['category']),
      brand: _optionalString(json, const ['brand']),
      isAvailable: _requiredBool(
        json,
        const ['isAvailable', 'is_available'],
      ),
      description: _optionalString(json, const ['description']),
      colors: _optionalStringList(json, const ['colors']),
      quantity: _optionalInt(json, const ['quantity', 'stock_quantity']),
      discount: _optionalDouble(json, const ['discount']),
      rating: _optionalDouble(json, const ['rating']),
    );
  }

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

  static Object? _valueFor(Map<String, dynamic> json, List<String> keys) {
    for (final key in keys) {
      if (json.containsKey(key)) return json[key];
    }

    return null;
  }

  static String _requiredString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _valueFor(json, keys);

    if (value == null || value.toString().trim().isEmpty) {
      throw FormatException('Missing required product field: ${keys.first}');
    }

    return value.toString();
  }

  static String _optionalString(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    return _valueFor(json, keys)?.toString() ?? '';
  }

  static double _requiredDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _valueFor(json, keys);
    final parsed = _toDouble(value);

    if (parsed == null) {
      throw FormatException('Invalid product field: ${keys.first}');
    }

    return parsed;
  }

  static double _optionalDouble(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    return _toDouble(_valueFor(json, keys)) ?? 0;
  }

  static int _optionalInt(Map<String, dynamic> json, List<String> keys) {
    final value = _valueFor(json, keys);

    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _requiredBool(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _valueFor(json, keys);

    if (value is bool) return value;
    if (value is num) return value != 0;

    switch (value?.toString().toLowerCase()) {
      case 'true':
      case '1':
        return true;
      case 'false':
      case '0':
        return false;
      default:
        throw FormatException('Invalid product field: ${keys.first}');
    }
  }

  static List<String> _optionalStringList(
    Map<String, dynamic> json,
    List<String> keys,
  ) {
    final value = _valueFor(json, keys);

    if (value is! List) return const [];
    return List<String>.unmodifiable(value.map((item) => item.toString()));
  }

  static double? _toDouble(Object? value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '');
  }
}

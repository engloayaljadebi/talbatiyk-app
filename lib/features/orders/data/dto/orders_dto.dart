class OrderItemDto {
  const OrderItemDto({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl = '',
  });

  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      productId: _requiredString(json, const ['productId', 'product_id']),
      productName: _requiredString(json, const [
        'productName',
        'product_name',
        'name',
      ]),
      unitPrice: _requiredDouble(json, const [
        'unitPrice',
        'unit_price',
        'price',
      ]),
      quantity: _requiredInt(json, const ['quantity']),
      imageUrl: _optionalString(json, const ['imageUrl', 'image_url']),
    );
  }

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String imageUrl;
}

class OrderDto {
  OrderDto({
    required this.id,
    required this.status,
    required List<OrderItemDto> items,
    required this.createdAt,
    this.notes = '',
  }) : items = List<OrderItemDto>.unmodifiable(items);

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final itemsValue = _valueFor(json, const ['items', 'order_items']);

    if (itemsValue is! List) {
      throw const FormatException('Order items must be a JSON list.');
    }

    return OrderDto(
      id: _requiredString(json, const ['id']),
      status: _requiredString(json, const ['status']),
      items: itemsValue
          .map((item) {
            if (item is! Map) {
              throw const FormatException(
                'Each order item must be a JSON object.',
              );
            }

            return OrderItemDto.fromJson(
              item.map((key, value) => MapEntry(key.toString(), value)),
            );
          })
          .toList(growable: false),
      createdAt: _requiredDateTime(json, const ['createdAt', 'created_at']),
      notes: _optionalString(json, const ['notes']),
    );
  }

  final String id;
  final String status;
  final List<OrderItemDto> items;
  final DateTime createdAt;
  final String notes;
}

Object? _valueFor(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key)) return json[key];
  }

  return null;
}

String _requiredString(Map<String, dynamic> json, List<String> keys) {
  final value = _valueFor(json, keys);

  if (value == null || value.toString().trim().isEmpty) {
    throw FormatException('Missing required order field: ${keys.first}');
  }

  return value.toString();
}

String _optionalString(Map<String, dynamic> json, List<String> keys) {
  return _valueFor(json, keys)?.toString() ?? '';
}

double _requiredDouble(Map<String, dynamic> json, List<String> keys) {
  final value = _valueFor(json, keys);
  final parsed = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  if (parsed == null) {
    throw FormatException('Invalid order field: ${keys.first}');
  }

  return parsed;
}

int _requiredInt(Map<String, dynamic> json, List<String> keys) {
  final value = _valueFor(json, keys);
  final parsed = value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '');

  if (parsed == null || parsed <= 0) {
    throw FormatException('Invalid order field: ${keys.first}');
  }

  return parsed;
}

DateTime _requiredDateTime(Map<String, dynamic> json, List<String> keys) {
  final value = _valueFor(json, keys);
  final parsed = DateTime.tryParse(value?.toString() ?? '');

  if (parsed == null) {
    throw FormatException('Invalid order field: ${keys.first}');
  }

  return parsed;
}

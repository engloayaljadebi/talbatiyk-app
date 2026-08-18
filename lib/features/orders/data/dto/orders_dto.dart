/// بيانات المورد القادمة من استجابة الـ API.
class OrderSupplierDto {
  const OrderSupplierDto({required this.id, required this.name});

  final String id;
  final String name;
}

/// بيانات منتج واحد داخل الطلبية القادمة من الـ API.
class OrderItemDto {
  const OrderItemDto({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.supplierId = '',
    this.supplierName = '',
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
      supplierId: _optionalString(json, const [
        'supplierId',
        'supplier_id',
        'vendorId',
        'vendor_id',
        'merchantId',
        'merchant_id',
      ]),
      supplierName: _optionalString(json, const [
        'supplierName',
        'supplier_name',
        'vendorName',
        'vendor_name',
        'merchantName',
        'merchant_name',
      ]),
      imageUrl: _optionalString(json, const ['imageUrl', 'image_url']),
    );
  }

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  /// المورد محفوظ على مستوى العنصر لدعم طلبية واحدة متعددة الموردين.
  final String supplierId;
  final String supplierName;

  final String imageUrl;
}

/// بيانات طلبية كاملة قادمة من الـ API.
class OrderDto {
  OrderDto({
    required this.id,
    required this.status,
    required List<OrderItemDto> items,
    required this.createdAt,
    this.supplier,
    this.notes = '',
  }) : items = List<OrderItemDto>.unmodifiable(items);

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    final Object? itemsValue = _valueFor(json, const ['items', 'order_items']);

    if (itemsValue is! List) {
      throw const FormatException('Order items must be a JSON list.');
    }

    return OrderDto(
      id: _requiredString(json, const ['id']),
      status: _requiredString(json, const ['status']),
      items: itemsValue
          .map((Object? item) {
            if (item is! Map) {
              throw const FormatException(
                'Each order item must be a JSON object.',
              );
            }

            return OrderItemDto.fromJson(
              item.map((Object? key, Object? value) {
                return MapEntry(key.toString(), value);
              }),
            );
          })
          .toList(growable: false),
      createdAt: _requiredDateTime(json, const ['createdAt', 'created_at']),
      supplier: _supplierFromJson(json),
      notes: _optionalString(json, const ['notes']),
    );
  }

  final String id;
  final String status;
  final List<OrderItemDto> items;
  final DateTime createdAt;

  /// بيانات المورد إن كانت موجودة في استجابة الخادم.
  final OrderSupplierDto? supplier;

  final String notes;
}

/// قراءة بيانات المورد من أكثر من صيغة API محتملة.
///
/// يدعم:
/// supplier: { id, name }
/// supplier_id + supplier_name
/// vendor_id + vendor_name
/// merchant_id + merchant_name
OrderSupplierDto? _supplierFromJson(Map<String, dynamic> json) {
  final Object? nestedSupplier = _valueFor(json, const [
    'supplier',
    'vendor',
    'merchant',
  ]);

  if (nestedSupplier is Map) {
    final Map<String, dynamic> supplierJson = nestedSupplier.map((
      Object? key,
      Object? value,
    ) {
      return MapEntry(key.toString(), value);
    });

    final String id = _optionalString(supplierJson, const [
      'id',
      'supplierId',
      'supplier_id',
      'vendorId',
      'vendor_id',
      'merchantId',
      'merchant_id',
    ]);

    final String name = _optionalString(supplierJson, const [
      'name',
      'supplierName',
      'supplier_name',
      'vendorName',
      'vendor_name',
      'merchantName',
      'merchant_name',
    ]);

    if (id.trim().isNotEmpty || name.trim().isNotEmpty) {
      return OrderSupplierDto(id: id, name: name);
    }
  }

  final String supplierId = _optionalString(json, const [
    'supplierId',
    'supplier_id',
    'vendorId',
    'vendor_id',
    'merchantId',
    'merchant_id',
  ]);

  final String supplierName = _optionalString(json, const [
    'supplierName',
    'supplier_name',
    'vendorName',
    'vendor_name',
    'merchantName',
    'merchant_name',
  ]);

  if (supplierId.trim().isEmpty && supplierName.trim().isEmpty) {
    return null;
  }

  return OrderSupplierDto(id: supplierId, name: supplierName);
}

Object? _valueFor(Map<String, dynamic> json, List<String> keys) {
  for (final String key in keys) {
    if (json.containsKey(key)) {
      return json[key];
    }
  }

  return null;
}

String _requiredString(Map<String, dynamic> json, List<String> keys) {
  final Object? value = _valueFor(json, keys);

  if (value == null || value.toString().trim().isEmpty) {
    throw FormatException('Missing required order field: ${keys.first}');
  }

  return value.toString();
}

String _optionalString(Map<String, dynamic> json, List<String> keys) {
  return _valueFor(json, keys)?.toString() ?? '';
}

double _requiredDouble(Map<String, dynamic> json, List<String> keys) {
  final Object? value = _valueFor(json, keys);

  final double? parsed = value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '');

  if (parsed == null) {
    throw FormatException('Invalid order field: ${keys.first}');
  }

  return parsed;
}

int _requiredInt(Map<String, dynamic> json, List<String> keys) {
  final Object? value = _valueFor(json, keys);

  final int? parsed = value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '');

  if (parsed == null || parsed <= 0) {
    throw FormatException('Invalid order field: ${keys.first}');
  }

  return parsed;
}

DateTime _requiredDateTime(Map<String, dynamic> json, List<String> keys) {
  final Object? value = _valueFor(json, keys);

  final DateTime? parsed = DateTime.tryParse(value?.toString() ?? '');

  if (parsed == null) {
    throw FormatException('Invalid order field: ${keys.first}');
  }

  return parsed;
}

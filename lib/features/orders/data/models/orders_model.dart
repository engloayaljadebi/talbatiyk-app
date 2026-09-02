/// نموذج المورد المستخدم داخل طبقة البيانات.
class OrderSupplierModel {
  const OrderSupplierModel({required this.id, required this.name});

  final String id;
  final String name;

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

/// نموذج منتج واحد داخل الطلبية.
class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.supplierId,
    required this.supplierName,
    this.imageUrl = '',
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String supplierId;
  final String supplierName;
  final String imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'supplier_id': supplierId,
      'supplier_name': supplierName,
      'image_url': imageUrl,
    };
  }
}

/// نموذج إرسال طلبية جديدة إلى مصدر البيانات.
class CreateOrderModel {
  CreateOrderModel({
    required List<OrderItemModel> items,
    required List<String> supplierIds,
    this.notes = '',
    this.idempotencyKey = '',
  }) : items = List<OrderItemModel>.unmodifiable(items),
       supplierIds = List<String>.unmodifiable(
         supplierIds.map((id) => id.trim()).toSet().toList()..sort(),
       ) {
    if (supplierIds.isEmpty ||
        supplierIds.any((supplierId) => supplierId.trim().isEmpty)) {
      throw ArgumentError.value(
        supplierIds,
        'supplierIds',
        'Create order requires at least one supplier.',
      );
    }
  }

  final List<OrderItemModel> items;
  final List<String> supplierIds;
  final String notes;

  /// Stable for the lifetime of one logical create-order operation.
  final String idempotencyKey;

  CreateOrderModel copyWith({
    List<OrderItemModel>? items,
    List<String>? supplierIds,
    String? notes,
    String? idempotencyKey,
  }) {
    return CreateOrderModel(
      items: items ?? this.items,
      supplierIds: supplierIds ?? this.supplierIds,
      notes: notes ?? this.notes,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items
          .map((OrderItemModel item) => item.toJson())
          .toList(growable: false),
      'supplier_ids': supplierIds,
      if (notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
  }
}

/// نموذج طلبية كاملة داخل طبقة البيانات.
class OrderModel {
  OrderModel({
    required this.id,
    required this.status,
    this.aggregateStatus = 'pending_responses',
    required List<OrderItemModel> items,
    required this.createdAt,
    this.supplier,
    this.notes = '',
  }) : items = List<OrderItemModel>.unmodifiable(items);

  final String id;
  final String status;
  final String aggregateStatus;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final OrderSupplierModel? supplier;
  final String notes;

  /// إنشاء نسخة جديدة من نموذج الطلب مع تعديل الحقول المطلوبة فقط.
  OrderModel copyWith({
    String? id,
    String? status,
    String? aggregateStatus,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    OrderSupplierModel? supplier,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      aggregateStatus: aggregateStatus ?? this.aggregateStatus,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
    );
  }
}

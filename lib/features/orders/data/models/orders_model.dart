class OrderItemModel {
  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.imageUrl = '',
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String imageUrl;

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'unit_price': unitPrice,
      'quantity': quantity,
      'image_url': imageUrl,
    };
  }
}

class CreateOrderModel {
  CreateOrderModel({required List<OrderItemModel> items, this.notes = ''})
    : items = List<OrderItemModel>.unmodifiable(items);

  final List<OrderItemModel> items;
  final String notes;

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(growable: false),
      if (notes.trim().isNotEmpty) 'notes': notes.trim(),
    };
  }
}

class OrderModel {
  OrderModel({
    required this.id,
    required this.status,
    required List<OrderItemModel> items,
    required this.createdAt,
    this.notes = '',
  }) : items = List<OrderItemModel>.unmodifiable(items);

  final String id;
  final String status;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final String notes;

  /// إنشاء نسخة جديدة من نموذج الطلب مع تعديل الحقول المطلوبة فقط.
  OrderModel copyWith({
    String? id,
    String? status,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    String? notes,
  }) {
    return OrderModel(
      id: id ?? this.id,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}

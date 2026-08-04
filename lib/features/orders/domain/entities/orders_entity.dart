enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForDelivery,
  outForDelivery,
  delivered,
  cancelled,
}

class OrderItemEntity {
  const OrderItemEntity({
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

  double get totalPrice => unitPrice * quantity;
}

class CreateOrderRequest {
  CreateOrderRequest({required List<OrderItemEntity> items, this.notes = ''})
    : items = List<OrderItemEntity>.unmodifiable(items) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Order items cannot be empty.');
    }
  }

  final List<OrderItemEntity> items;
  final String notes;

  int get totalQuantity {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }
}

class OrderEntity {
  OrderEntity({
    required this.id,
    required this.status,
    required List<OrderItemEntity> items,
    required this.createdAt,
    this.notes = '',
  }) : items = List<OrderItemEntity>.unmodifiable(items);

  final String id;
  final OrderStatus status;
  final List<OrderItemEntity> items;
  final DateTime createdAt;
  final String notes;

  int get totalQuantity {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return items.fold(0, (total, item) => total + item.totalPrice);
  }
}

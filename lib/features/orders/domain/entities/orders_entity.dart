enum OrderStatus {
  pending,
  confirmed,
  preparing,
  readyForDelivery,
  outForDelivery,
  delivered,
  cancelled,
}

/// منطق انتقال الطلبية بين الحالات.
///
/// يوجد هنا داخل Domain لأنه من قواعد العمل،
/// ولا يعتمد على Flutter أو تصميم الواجهة.
extension OrderStatusFlow on OrderStatus {
  /// الحالة التالية الطبيعية للطلبية.
  OrderStatus? get nextStatus {
    switch (this) {
      case OrderStatus.pending:
        return OrderStatus.confirmed;
      case OrderStatus.confirmed:
        return OrderStatus.preparing;
      case OrderStatus.preparing:
        return OrderStatus.readyForDelivery;
      case OrderStatus.readyForDelivery:
        return OrderStatus.outForDelivery;
      case OrderStatus.outForDelivery:
        return OrderStatus.delivered;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  /// هل وصلت الطلبية إلى حالة نهائية؟
  bool get isFinal {
    return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  }

  /// يتحقق أن الانتقال المطلوب مسموح.
  ///
  /// يمكن الانتقال إلى المرحلة التالية فقط،
  /// أو إلغاء الطلب قبل وصوله إلى حالة نهائية.
  bool canTransitionTo(OrderStatus newStatus) {
    if (isFinal) {
      return false;
    }

    if (newStatus == OrderStatus.cancelled) {
      return true;
    }

    return nextStatus == newStatus;
  }
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

  /// إنشاء نسخة جديدة من الطلبية مع تعديل الحقول المطلوبة فقط.
  OrderEntity copyWith({
    String? id,
    OrderStatus? status,
    List<OrderItemEntity>? items,
    DateTime? createdAt,
    String? notes,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
    );
  }
}

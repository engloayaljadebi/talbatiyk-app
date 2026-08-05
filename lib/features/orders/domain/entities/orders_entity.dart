/// الحالات المتاحة للطلبية.
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
/// يوجد داخل Domain لأنه يمثل قواعد العمل،
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

/// نسخة بيانات المورد المحفوظة مع الطلبية.
///
/// نحفظ الاسم مع المعرّف حتى تبقى بيانات الطلبية قابلة للعرض
/// حتى أثناء العمل دون إنترنت.
class OrderSupplierEntity {
  const OrderSupplierEntity({required this.id, required this.name});

  /// المعرّف الثابت للمورد.
  final String id;

  /// اسم المورد وقت إنشاء الطلبية.
  final String name;

  /// هل توجد بيانات مفيدة قابلة للعرض؟
  bool get hasData {
    return id.trim().isNotEmpty || name.trim().isNotEmpty;
  }
}

/// منتج واحد داخل الطلبية.
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

/// بيانات إنشاء طلبية جديدة.
class CreateOrderRequest {
  CreateOrderRequest({
    required List<OrderItemEntity> items,
    this.supplier,
    this.notes = '',
  }) : items = List<OrderItemEntity>.unmodifiable(items) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Order items cannot be empty.');
    }
  }

  final List<OrderItemEntity> items;

  /// المورد الذي ستُرسل إليه الطلبية.
  final OrderSupplierEntity? supplier;

  final String notes;

  int get totalQuantity {
    return items.fold(
      0,
      (int total, OrderItemEntity item) => total + item.quantity,
    );
  }

  double get totalPrice {
    return items.fold(
      0,
      (double total, OrderItemEntity item) => total + item.totalPrice,
    );
  }
}

/// كيان الطلبية المستخدم في طبقة الأعمال والواجهة.
class OrderEntity {
  OrderEntity({
    required this.id,
    required this.status,
    required List<OrderItemEntity> items,
    required this.createdAt,
    this.supplier,
    this.notes = '',
  }) : items = List<OrderItemEntity>.unmodifiable(items);

  final String id;
  final OrderStatus status;
  final List<OrderItemEntity> items;
  final DateTime createdAt;

  /// بيانات المورد المرتبط بالطلبية.
  ///
  /// اختيارية لدعم الطلبيات القديمة التي أُنشئت قبل إضافة المورد.
  final OrderSupplierEntity? supplier;

  final String notes;

  int get totalQuantity {
    return items.fold(
      0,
      (int total, OrderItemEntity item) => total + item.quantity,
    );
  }

  double get totalPrice {
    return items.fold(
      0,
      (double total, OrderItemEntity item) => total + item.totalPrice,
    );
  }

  /// إنشاء نسخة جديدة من الطلبية مع تعديل الحقول المطلوبة فقط.
  OrderEntity copyWith({
    String? id,
    OrderStatus? status,
    List<OrderItemEntity>? items,
    DateTime? createdAt,
    OrderSupplierEntity? supplier,
    String? notes,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      supplier: supplier ?? this.supplier,
      notes: notes ?? this.notes,
    );
  }
}

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

/// Server-authoritative lifecycle derived from supplier responses,
/// customer selections, and per-recipient fulfillment.
enum OrderAggregateStatus {
  pendingResponses,
  responsesReceived,
  suppliersSelected,
  inFulfillment,
  partiallyCompleted,
  completed,
  cancelled,
  expired,
}

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
    required this.supplierId,
    required this.supplierName,
    this.imageUrl = '',
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  /// المورد الخاص بهذا المنتج داخل الطلبية.
  ///
  /// وجود المورد على مستوى العنصر يسمح للطلبية الواحدة
  /// باحتواء منتجات من عدة موردين.
  final String supplierId;
  final String supplierName;

  final String imageUrl;

  double get totalPrice => unitPrice * quantity;
}

/// بيانات إنشاء طلبية جديدة.
class CreateOrderRequest {
  CreateOrderRequest({
    required List<OrderItemEntity> items,
    required List<String> supplierIds,
    this.notes = '',
  }) : items = List<OrderItemEntity>.unmodifiable(items),
       supplierIds = List<String>.unmodifiable(
         supplierIds.map((id) => id.trim()).toSet().toList()..sort(),
       ) {
    if (items.isEmpty) {
      throw ArgumentError.value(items, 'items', 'Order items cannot be empty.');
    }

    if (supplierIds.isEmpty ||
        supplierIds.any((supplierId) => supplierId.isEmpty)) {
      throw ArgumentError.value(
        supplierIds,
        'supplierIds',
        'Order must target at least one supplier.',
      );
    }
  }

  final List<OrderItemEntity> items;

  /// المورد الذي ستُرسل إليه الطلبية.
  final List<String> supplierIds;

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
    this.aggregateStatus = OrderAggregateStatus.pendingResponses,
    required List<OrderItemEntity> items,
    required this.createdAt,
    this.supplier,
    this.notes = '',
  }) : items = List<OrderItemEntity>.unmodifiable(items);

  final String id;

  /// Legacy order status retained temporarily for compatibility.
  final OrderStatus status;

  /// Last known server-authoritative aggregate lifecycle.
  final OrderAggregateStatus aggregateStatus;

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
    OrderAggregateStatus? aggregateStatus,
    List<OrderItemEntity>? items,
    DateTime? createdAt,
    OrderSupplierEntity? supplier,
    String? notes,
  }) {
    return OrderEntity(
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

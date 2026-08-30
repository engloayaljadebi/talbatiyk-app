enum ReceivedOrderAvailability { full, partial, unavailable }

final class ReceivedOrderItemEntity {
  const ReceivedOrderItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.requestedQuantity,
    this.imageUrl,
  });

  final String id;
  final String productId;
  final String productName;
  final String unitPrice;
  final int requestedQuantity;
  final String? imageUrl;
}

final class ReceivedOrderItemResponseEntity {
  const ReceivedOrderItemResponseEntity({
    required this.id,
    required this.orderRecipientItemId,
    required this.requestedQuantity,
    required this.availableQuantity,
    required this.availability,
    this.offeredUnitPrice,
    this.responseNotes,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String orderRecipientItemId;
  final int requestedQuantity;
  final int availableQuantity;
  final ReceivedOrderAvailability availability;
  final String? offeredUnitPrice;
  final String? responseNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

final class ReceivedOrderResponseEntity {
  ReceivedOrderResponseEntity({
    required this.id,
    required this.orderRecipientId,
    required List<ReceivedOrderItemResponseEntity> items,
    this.createdAt,
    this.updatedAt,
  }) : items = List<ReceivedOrderItemResponseEntity>.unmodifiable(items);

  final String id;
  final String orderRecipientId;
  final List<ReceivedOrderItemResponseEntity> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

final class ReceivedOrderEntity {
  ReceivedOrderEntity({
    required this.id,
    required this.orderId,
    required this.supplierId,
    required this.supplierName,
    required this.orderStatus,
    required List<ReceivedOrderItemEntity> items,
    this.notes,
    this.response,
    this.createdAt,
    this.updatedAt,
  }) : items = List<ReceivedOrderItemEntity>.unmodifiable(items);

  final String id;
  final String orderId;
  final String supplierId;
  final String supplierName;
  final String orderStatus;
  final String? notes;
  final List<ReceivedOrderItemEntity> items;
  final ReceivedOrderResponseEntity? response;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get hasResponse => response != null;
}

final class SubmitReceivedOrderItemResponse {
  const SubmitReceivedOrderItemResponse({
    required this.orderRecipientItemId,
    required this.availability,
    required this.availableQuantity,
    this.offeredUnitPrice,
    this.responseNotes,
  });

  final String orderRecipientItemId;
  final ReceivedOrderAvailability availability;
  final int availableQuantity;
  final num? offeredUnitPrice;
  final String? responseNotes;
}

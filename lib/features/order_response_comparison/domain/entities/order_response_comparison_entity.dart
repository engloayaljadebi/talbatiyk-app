import '../../../orders/domain/entities/orders_entity.dart';

enum OrderResponseAvailability { full, partial, unavailable }

final class OrderResponseComparisonEntity {
  const OrderResponseComparisonEntity({
    required this.id,
    required this.version,
    required this.status,
    required this.aggregateStatus,
    required this.notes,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final int version;

  /// Legacy server field retained for compatibility.
  final String status;

  /// Server-authoritative lifecycle for the whole order.
  final OrderAggregateStatus aggregateStatus;

  final String? notes;
  final List<OrderResponseComparisonItemEntity> items;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

final class OrderResponseComparisonItemEntity {
  const OrderResponseComparisonItemEntity({
    required this.id,
    required this.productId,
    required this.productName,
    required this.requestedQuantity,
    required this.orderUnitPrice,
    required this.supplier,
    required this.response,
    required this.selection,
  });

  final String id;
  final String productId;
  final String productName;
  final int requestedQuantity;
  final String orderUnitPrice;
  final OrderResponseSupplierEntity supplier;
  final OrderResponseItemResponseEntity? response;
  final OrderResponseSelectionEntity? selection;
}

final class OrderResponseSupplierEntity {
  const OrderResponseSupplierEntity({
    required this.recipientId,
    required this.supplierId,
    required this.supplierName,
  });

  final String recipientId;
  final String supplierId;
  final String supplierName;
}

final class OrderResponseItemResponseEntity {
  const OrderResponseItemResponseEntity({
    required this.id,
    required this.orderRecipientItemId,
    required this.requestedQuantity,
    required this.availableQuantity,
    required this.availability,
    required this.offeredUnitPrice,
    required this.responseNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String orderRecipientItemId;
  final int requestedQuantity;
  final int availableQuantity;
  final OrderResponseAvailability availability;
  final String? offeredUnitPrice;
  final String? responseNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}

final class OrderResponseSelectionEntity {
  const OrderResponseSelectionEntity({
    required this.id,
    required this.orderRecipientItemResponseId,
    required this.selectedQuantity,
  });

  final String id;
  final String orderRecipientItemResponseId;
  final int selectedQuantity;
}

final class OrderResponseSelectionInput {
  const OrderResponseSelectionInput({
    required this.orderRecipientItemResponseId,
    required this.selectedQuantity,
  });

  final String orderRecipientItemResponseId;
  final int selectedQuantity;
}

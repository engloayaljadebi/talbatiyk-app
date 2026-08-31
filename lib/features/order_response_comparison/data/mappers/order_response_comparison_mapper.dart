import 'package:talbatiyk_api/talbatiyk_api.dart' as api;

import '../../../orders/domain/entities/orders_entity.dart';
import '../../domain/entities/order_response_comparison_entity.dart';

final class OrderResponseComparisonMapper {
  const OrderResponseComparisonMapper._();

  static OrderResponseComparisonEntity fromResource(
    api.OrderResponseComparisonResource resource,
  ) {
    return OrderResponseComparisonEntity(
      id: resource.id,
      version: resource.version,
      status: resource.status,
      aggregateStatus: _aggregateStatusFromApi(resource.aggregateStatus),
      notes: resource.notes,
      items: List<OrderResponseComparisonItemEntity>.unmodifiable(
        resource.items.map(_itemFromResource),
      ),
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  static OrderResponseComparisonItemEntity _itemFromResource(
    api.OrderResponseComparisonItemResource resource,
  ) {
    final supplier = resource.supplier;
    final response = resource.response;
    final selection = resource.selection;

    return OrderResponseComparisonItemEntity(
      id: resource.id,
      productId: resource.productId,
      productName: resource.productName,
      requestedQuantity: resource.requestedQuantity,
      orderUnitPrice: resource.orderUnitPrice,
      supplier: OrderResponseSupplierEntity(
        recipientId: supplier.recipientId,
        supplierId: supplier.supplierId,
        supplierName: supplier.supplierName,
      ),
      response: response == null
          ? null
          : OrderResponseItemResponseEntity(
              id: response.id,
              orderRecipientItemId: response.orderRecipientItemId,
              requestedQuantity: response.requestedQuantity,
              availableQuantity: response.availableQuantity,
              availability: _availabilityFromApi(response.availabilityStatus),
              offeredUnitPrice: response.offeredUnitPrice,
              responseNotes: response.responseNotes,
              createdAt: response.createdAt,
              updatedAt: response.updatedAt,
            ),
      selection: selection == null
          ? null
          : OrderResponseSelectionEntity(
              id: selection.id,
              orderRecipientItemResponseId:
                  selection.orderRecipientItemResponseId,
              selectedQuantity: selection.selectedQuantity,
            ),
    );
  }

  static OrderAggregateStatus _aggregateStatusFromApi(
    api.OrderAggregateStatus value,
  ) {
    if (value == api.OrderAggregateStatus.pendingResponses) {
      return OrderAggregateStatus.pendingResponses;
    }
    if (value == api.OrderAggregateStatus.responsesReceived) {
      return OrderAggregateStatus.responsesReceived;
    }
    if (value == api.OrderAggregateStatus.suppliersSelected) {
      return OrderAggregateStatus.suppliersSelected;
    }
    if (value == api.OrderAggregateStatus.inFulfillment) {
      return OrderAggregateStatus.inFulfillment;
    }
    if (value == api.OrderAggregateStatus.partiallyCompleted) {
      return OrderAggregateStatus.partiallyCompleted;
    }
    if (value == api.OrderAggregateStatus.completed) {
      return OrderAggregateStatus.completed;
    }
    if (value == api.OrderAggregateStatus.cancelled) {
      return OrderAggregateStatus.cancelled;
    }
    if (value == api.OrderAggregateStatus.expired) {
      return OrderAggregateStatus.expired;
    }

    throw StateError('Unsupported aggregate order status: $value');
  }

  static OrderResponseAvailability _availabilityFromApi(
    api.AvailabilityStatus value,
  ) {
    if (value == api.AvailabilityStatus.full) {
      return OrderResponseAvailability.full;
    }

    if (value == api.AvailabilityStatus.partial) {
      return OrderResponseAvailability.partial;
    }

    if (value == api.AvailabilityStatus.unavailable) {
      return OrderResponseAvailability.unavailable;
    }

    throw StateError('Unsupported availability status: $value');
  }
}

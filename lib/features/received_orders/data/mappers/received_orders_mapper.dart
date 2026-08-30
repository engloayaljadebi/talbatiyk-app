import 'package:talbatiyk_api/talbatiyk_api.dart' as api;

import '../../domain/entities/received_order_entity.dart';

abstract final class ReceivedOrdersMapper {
  static ReceivedOrderEntity fromResource(api.OrderRecipientResource resource) {
    return ReceivedOrderEntity(
      id: resource.id,
      orderId: resource.orderId,
      supplierId: resource.supplierId,
      supplierName: resource.supplierName,
      orderStatus: resource.orderStatus,
      fulfillmentStatus: _fulfillmentStatusFromApi(resource.fulfillmentStatus),
      fulfillmentVersion: resource.fulfillmentVersion,
      notes: resource.notes,
      items: resource.items.map(_itemFromResource).toList(growable: false),
      response: resource.response == null
          ? null
          : responseFromResource(resource.response!),
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  static ReceivedOrderResponseEntity responseFromResource(
    api.OrderRecipientResponseResource resource,
  ) {
    return ReceivedOrderResponseEntity(
      id: resource.id,
      orderRecipientId: resource.orderRecipientId,
      items: resource.items
          .map(_responseItemFromResource)
          .toList(growable: false),
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  static ReceivedOrderItemEntity _itemFromResource(
    api.OrderRecipientItemResource resource,
  ) {
    return ReceivedOrderItemEntity(
      id: resource.id,
      productId: resource.productId,
      productName: resource.productName,
      unitPrice: resource.unitPrice,
      requestedQuantity: resource.requestedQuantity,
      selectedQuantity: resource.selectedQuantity,
      imageUrl: resource.imageUrl,
    );
  }

  static ReceivedOrderItemResponseEntity _responseItemFromResource(
    api.OrderRecipientItemResponseResource resource,
  ) {
    return ReceivedOrderItemResponseEntity(
      id: resource.id,
      orderRecipientItemId: resource.orderRecipientItemId,
      requestedQuantity: resource.requestedQuantity,
      availableQuantity: resource.availableQuantity,
      availability: _availabilityFromApi(resource.availabilityStatus),
      offeredUnitPrice: resource.offeredUnitPrice,
      responseNotes: resource.responseNotes,
      createdAt: resource.createdAt,
      updatedAt: resource.updatedAt,
    );
  }

  static ReceivedOrderFulfillmentStatus? _fulfillmentStatusFromApi(
    api.FulfillmentStatus? value,
  ) {
    if (value == null) {
      return null;
    }

    if (value == api.FulfillmentStatus.confirmed) {
      return ReceivedOrderFulfillmentStatus.confirmed;
    }

    if (value == api.FulfillmentStatus.preparing) {
      return ReceivedOrderFulfillmentStatus.preparing;
    }

    if (value == api.FulfillmentStatus.readyForDelivery) {
      return ReceivedOrderFulfillmentStatus.readyForDelivery;
    }

    if (value == api.FulfillmentStatus.outForDelivery) {
      return ReceivedOrderFulfillmentStatus.outForDelivery;
    }

    if (value == api.FulfillmentStatus.delivered) {
      return ReceivedOrderFulfillmentStatus.delivered;
    }

    throw StateError('Unsupported supplier fulfillment status: $value');
  }

  static ReceivedOrderAvailability _availabilityFromApi(
    api.AvailabilityStatus value,
  ) {
    if (value == api.AvailabilityStatus.full) {
      return ReceivedOrderAvailability.full;
    }

    if (value == api.AvailabilityStatus.partial) {
      return ReceivedOrderAvailability.partial;
    }

    if (value == api.AvailabilityStatus.unavailable) {
      return ReceivedOrderAvailability.unavailable;
    }

    throw StateError('Unsupported supplier availability status: $value');
  }
}

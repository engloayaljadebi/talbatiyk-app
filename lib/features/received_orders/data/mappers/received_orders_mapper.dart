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

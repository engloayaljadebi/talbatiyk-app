import 'package:built_collection/built_collection.dart';
import 'package:dio/dio.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart' as api;

import '../../../domain/entities/received_order_entity.dart';
import '../../../domain/errors/stale_recipient_fulfillment_version_exception.dart';

abstract interface class ReceivedOrdersRemoteDataSource {
  Future<BuiltList<api.OrderRecipientResource>> index({
    required String businessId,
  });

  Future<api.OrderRecipientResponseResource> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  });

  Future<api.OrderRecipientResource> updateFulfillment({
    required String businessId,
    required String recipientId,
    required int expectedVersion,
    required ReceivedOrderFulfillmentStatus status,
  });
}

final class ReceivedOrdersRemoteDataSourceImpl
    implements ReceivedOrdersRemoteDataSource {
  ReceivedOrdersRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<BuiltList<api.OrderRecipientResource>> index({
    required String businessId,
  }) async {
    final business = businessId.trim();

    if (business.isEmpty) {
      throw ArgumentError.value(
        businessId,
        'businessId',
        'Business id cannot be empty.',
      );
    }

    final response = await _apiClient.supplierOrders.supplierOrderIndex(
      business: business,
    );

    final body = response.data;

    if (body == null) {
      throw StateError('Received orders response does not contain data.');
    }

    return body.data;
  }

  @override
  Future<api.OrderRecipientResponseResource> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  }) async {
    final business = businessId.trim();
    final recipient = recipientId.trim();
    final key = idempotencyKey.trim();

    if (business.isEmpty) {
      throw ArgumentError.value(
        businessId,
        'businessId',
        'Business id cannot be empty.',
      );
    }

    if (recipient.isEmpty) {
      throw ArgumentError.value(
        recipientId,
        'recipientId',
        'Recipient id cannot be empty.',
      );
    }

    if (key.isEmpty) {
      throw ArgumentError.value(
        idempotencyKey,
        'idempotencyKey',
        'Supplier response requires an idempotency key.',
      );
    }

    if (items.isEmpty) {
      throw ArgumentError.value(
        items,
        'items',
        'Supplier response must contain recipient items.',
      );
    }

    final request = api.SubmitSupplierOrderResponseRequest((builder) {
      builder.items.replace(
        BuiltList<api.SubmitSupplierOrderResponseRequestItemsInner>(
          items.map(_requestItemToApi),
        ),
      );
    });

    final response = await _apiClient.supplierOrderResponses
        .supplierOrderResponseStore(
          business: business,
          recipient: recipient,
          idempotencyKey: key,
          submitSupplierOrderResponseRequest: request,
        );

    final body = response.data;

    if (body == null) {
      throw StateError('Supplier order response does not contain data.');
    }

    return body.data;
  }

  @override
  Future<api.OrderRecipientResource> updateFulfillment({
    required String businessId,
    required String recipientId,
    required int expectedVersion,
    required ReceivedOrderFulfillmentStatus status,
  }) async {
    final business = businessId.trim();
    final recipient = recipientId.trim();

    if (business.isEmpty) {
      throw ArgumentError.value(
        businessId,
        'businessId',
        'Business id cannot be empty.',
      );
    }

    if (recipient.isEmpty) {
      throw ArgumentError.value(
        recipientId,
        'recipientId',
        'Recipient id cannot be empty.',
      );
    }

    if (expectedVersion <= 0) {
      throw ArgumentError.value(
        expectedVersion,
        'expectedVersion',
        'Expected fulfillment version must be positive.',
      );
    }

    if (status == ReceivedOrderFulfillmentStatus.confirmed) {
      throw ArgumentError.value(
        status,
        'status',
        'Confirmed is a derived state and cannot be submitted.',
      );
    }

    final request = api.UpdateSupplierFulfillmentRequest((builder) {
      builder
        ..expectedVersion = expectedVersion
        ..status = _fulfillmentStatusToApi(status);
    });

    try {
      final response = await _apiClient.supplierOrderFulfillment
          .supplierOrderFulfillmentUpdate(
            business: business,
            recipient: recipient,
            updateSupplierFulfillmentRequest: request,
          );

      final body = response.data;

      if (body == null) {
        throw StateError(
          'Supplier fulfillment response does not contain data.',
        );
      }

      return body.data;
    } on DioException catch (error) {
      if (error.response?.statusCode == 409) {
        throw const StaleRecipientFulfillmentVersionException();
      }

      rethrow;
    }
  }

  api.SubmitSupplierOrderResponseRequestItemsInner _requestItemToApi(
    SubmitReceivedOrderItemResponse item,
  ) {
    final itemId = item.orderRecipientItemId.trim();

    if (itemId.isEmpty) {
      throw ArgumentError.value(
        item.orderRecipientItemId,
        'orderRecipientItemId',
        'Recipient item id cannot be empty.',
      );
    }

    if (item.availableQuantity < 0) {
      throw ArgumentError.value(
        item.availableQuantity,
        'availableQuantity',
        'Available quantity cannot be negative.',
      );
    }

    return api.SubmitSupplierOrderResponseRequestItemsInner((builder) {
      builder
        ..orderRecipientItemId = itemId
        ..availabilityStatus = _availabilityToApi(item.availability)
        ..availableQuantity = item.availableQuantity;

      final offeredUnitPrice = item.offeredUnitPrice;
      if (offeredUnitPrice != null) {
        builder.offeredUnitPrice = offeredUnitPrice;
      }

      final notes = item.responseNotes?.trim();
      if (notes != null && notes.isNotEmpty) {
        builder.responseNotes = notes;
      }
    });
  }

  api.UpdateSupplierFulfillmentRequestStatusEnum _fulfillmentStatusToApi(
    ReceivedOrderFulfillmentStatus value,
  ) {
    return switch (value) {
      ReceivedOrderFulfillmentStatus.preparing =>
        api.UpdateSupplierFulfillmentRequestStatusEnum.preparing,
      ReceivedOrderFulfillmentStatus.readyForDelivery =>
        api.UpdateSupplierFulfillmentRequestStatusEnum.readyForDelivery,
      ReceivedOrderFulfillmentStatus.outForDelivery =>
        api.UpdateSupplierFulfillmentRequestStatusEnum.outForDelivery,
      ReceivedOrderFulfillmentStatus.delivered =>
        api.UpdateSupplierFulfillmentRequestStatusEnum.delivered,
      ReceivedOrderFulfillmentStatus.confirmed => throw ArgumentError.value(
        value,
        'value',
        'Confirmed is not a writable fulfillment status.',
      ),
    };
  }

  api.AvailabilityStatus _availabilityToApi(ReceivedOrderAvailability value) {
    return switch (value) {
      ReceivedOrderAvailability.full => api.AvailabilityStatus.full,
      ReceivedOrderAvailability.partial => api.AvailabilityStatus.partial,
      ReceivedOrderAvailability.unavailable =>
        api.AvailabilityStatus.unavailable,
    };
  }
}

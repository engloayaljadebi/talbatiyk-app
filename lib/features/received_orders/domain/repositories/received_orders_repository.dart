import '../entities/received_order_entity.dart';

abstract interface class ReceivedOrdersRepository {
  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  });

  Future<ReceivedOrderResponseEntity> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  });

  Future<ReceivedOrderEntity> updateFulfillment({
    required String businessId,
    required String recipientId,
    required int expectedVersion,
    required ReceivedOrderFulfillmentStatus status,
  });
}

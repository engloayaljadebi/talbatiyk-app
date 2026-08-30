import '../entities/received_order_entity.dart';
import '../repositories/received_orders_repository.dart';

final class ReceivedOrdersUseCase {
  ReceivedOrdersUseCase(this._repository);

  final ReceivedOrdersRepository _repository;

  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  }) {
    return _repository.getReceivedOrders(businessId: businessId);
  }

  Future<ReceivedOrderResponseEntity> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  }) {
    return _repository.submitResponse(
      businessId: businessId,
      recipientId: recipientId,
      idempotencyKey: idempotencyKey,
      items: items,
    );
  }

  Future<ReceivedOrderEntity> updateFulfillment({
    required String businessId,
    required String recipientId,
    required int expectedVersion,
    required ReceivedOrderFulfillmentStatus status,
  }) {
    return _repository.updateFulfillment(
      businessId: businessId,
      recipientId: recipientId,
      expectedVersion: expectedVersion,
      status: status,
    );
  }
}

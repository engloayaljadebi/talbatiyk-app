import '../../domain/entities/received_order_entity.dart';
import '../../domain/repositories/received_orders_repository.dart';
import '../datasources/remote/received_orders_remote_datasource.dart';
import '../mappers/received_orders_mapper.dart';

final class ReceivedOrdersRepositoryImpl implements ReceivedOrdersRepository {
  ReceivedOrdersRepositoryImpl(this._remoteDataSource);

  final ReceivedOrdersRemoteDataSource _remoteDataSource;

  @override
  Future<List<ReceivedOrderEntity>> getReceivedOrders({
    required String businessId,
  }) async {
    final resources = await _remoteDataSource.index(businessId: businessId);

    return List<ReceivedOrderEntity>.unmodifiable(
      resources.map(ReceivedOrdersMapper.fromResource),
    );
  }

  @override
  Future<ReceivedOrderResponseEntity> submitResponse({
    required String businessId,
    required String recipientId,
    required String idempotencyKey,
    required List<SubmitReceivedOrderItemResponse> items,
  }) async {
    final resource = await _remoteDataSource.submitResponse(
      businessId: businessId,
      recipientId: recipientId,
      idempotencyKey: idempotencyKey,
      items: items,
    );

    return ReceivedOrdersMapper.responseFromResource(resource);
  }
}

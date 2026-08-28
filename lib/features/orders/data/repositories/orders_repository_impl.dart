import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/orders_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/local/orders_local_datasource.dart';
import '../datasources/orders_datasource.dart';
import '../mappers/orders_mapper.dart';
import '../models/orders_model.dart';
import 'package:uuid/uuid.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this.localDataSource, {this.remoteDataSource});

  final OrdersLocalDataSource localDataSource;
  final OrdersDataSource? remoteDataSource;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final models = await localDataSource.getOrders();

    return List<OrderEntity>.unmodifiable(models.map(OrdersMapper.toEntity));
  }

  @override
  Future<OrderEntity> createOrder(CreateOrderRequest request) async {
    final CreateOrderModel
    createModel = OrdersMapper.toCreateModel(request).copyWith(
      // One logical create gets one idempotency key before local persistence
      // or network I/O.
      idempotencyKey: Uuid().v4(),
    );

    // Local Order + Outbox are committed atomically before the first
    // network attempt. Drift remains the durable source of truth.
    final OrderModel localOrder = await localDataSource.createOrder(
      createModel,
    );

    final OrdersDataSource? remote = remoteDataSource;

    if (remote == null) {
      return OrdersMapper.toEntity(localOrder);
    }

    final String operationId = 'order:create:${localOrder.id}';

    late final OrderModel remoteOrder;

    try {
      remoteOrder = await remote.createOrder(createModel);
    } catch (error) {
      if (_shouldRemainQueued(error)) {
        // Retryable or ambiguous transport/server outcomes remain durable.
        // SyncCoordinator will replay the same logical operation later.
        return OrdersMapper.toEntity(localOrder);
      }

      if (_isDefinitiveRemoteRejection(error)) {
        // A definitive client-side rejection was not accepted by the server.
        await localDataSource.discardPendingCreate(
          localOrderId: localOrder.id,
          operationId: operationId,
        );
      }

      // Unknown/non-Dio failures are surfaced, but their durable local state
      // is retained because the remote outcome may be ambiguous.
      rethrow;
    }
    try {
      await localDataSource.completeCreateSync(
        localOrderId: localOrder.id,
        operationId: operationId,
        remoteOrder: remoteOrder,
      );

      return OrdersMapper.toEntity(remoteOrder);
    } catch (_) {
      // The server already accepted the logical operation. Keep the durable
      // local Order + Outbox so a later idempotent replay can reconcile it.
      return OrdersMapper.toEntity(localOrder);
    }
  }

  @override
  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    final OrderModel updatedOrder = await localDataSource.updateOrderStatus(
      orderId: orderId,
      status: OrdersMapper.statusToDataValue(status),
    );

    return OrdersMapper.toEntity(updatedOrder);
  }

  bool _shouldRemainQueued(Object error) {
    if (_isConnectivityFailure(error)) {
      return true;
    }

    if (error is! DioException || error.type != DioExceptionType.badResponse) {
      return false;
    }

    final int? statusCode = error.response?.statusCode;

    if (statusCode == null) {
      return false;
    }

    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  bool _isDefinitiveRemoteRejection(Object error) {
    if (error is! DioException || error.type != DioExceptionType.badResponse) {
      return false;
    }

    final int? statusCode = error.response?.statusCode;

    if (statusCode == null) {
      return false;
    }

    return statusCode >= 400 &&
        statusCode < 500 &&
        statusCode != 408 &&
        statusCode != 429;
  }

  bool _isConnectivityFailure(Object error) {
    if (error is! DioException) {
      return false;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.unknown:
        return error.error is SocketException;

      default:
        return false;
    }
  }
}

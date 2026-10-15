import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/orders_entity.dart';
import '../../../auth/domain/services/account_session_fence.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/local/orders_local_datasource.dart';
import '../datasources/orders_datasource.dart';
import '../mappers/orders_mapper.dart';
import '../models/orders_model.dart';
import 'package:uuid/uuid.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(
    this.localDataSource, {
    required AccountSessionFence sessionFence,
    this.remoteDataSource,
  }) : _sessionFence = sessionFence;

  final OrdersLocalDataSource localDataSource;
  final OrdersDataSource? remoteDataSource;
  final AccountSessionFence _sessionFence;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final lease = _sessionFence.capture();
    final remote = remoteDataSource;

    if (remote != null) {
      try {
        lease.ensureCurrent();

        final remoteOrders = await remote.getOrders();

        lease.ensureCurrent();

        await localDataSource.replaceServerSnapshotPreservingPendingCreates(
          remoteOrders,
        );

        lease.ensureCurrent();
      } catch (error) {
        lease.ensureCurrent();

        if (!_shouldUseLocalReadFallback(error)) {
          rethrow;
        }
      }
    }

    lease.ensureCurrent();

    final models = await localDataSource.getOrders();

    lease.ensureCurrent();

    return List<OrderEntity>.unmodifiable(models.map(OrdersMapper.toEntity));
  }

  @override
  Future<OrderEntity> createOrder(CreateOrderRequest request) async {
    final lease = _sessionFence.capture();

    final CreateOrderModel createModel = OrdersMapper.toCreateModel(
      request,
    ).copyWith(idempotencyKey: Uuid().v4());

    lease.ensureCurrent();

    // Durable local Order + Outbox before attempting the network.
    final localOrder = await localDataSource.createOrder(createModel);

    // An account switch here must prevent the first remote attempt.
    lease.ensureCurrent();

    final remote = remoteDataSource;

    if (remote == null) {
      lease.ensureCurrent();
      return OrdersMapper.toEntity(localOrder);
    }

    final operationId = 'order:create:${localOrder.id}';

    late final OrderModel remoteOrder;

    try {
      lease.ensureCurrent();

      remoteOrder = await remote.createOrder(createModel);

      lease.ensureCurrent();
    } catch (error) {
      // Invalidation must never become an offline success result.
      lease.ensureCurrent();

      if (_shouldRemainQueued(error)) {
        return OrdersMapper.toEntity(localOrder);
      }

      if (_isDefinitiveRemoteRejection(error)) {
        await localDataSource.discardPendingCreate(
          localOrderId: localOrder.id,
          operationId: operationId,
        );

        lease.ensureCurrent();
      }

      // Preserve local state for unknown or ambiguous outcomes.
      rethrow;
    }

    try {
      lease.ensureCurrent();

      await localDataSource.completeCreateSync(
        localOrderId: localOrder.id,
        operationId: operationId,
        remoteOrder: remoteOrder,
      );

      lease.ensureCurrent();

      return OrdersMapper.toEntity(remoteOrder);
    } catch (_) {
      // Preserve idempotent replay for a reconciliation failure,
      // but do not hide a change of authenticated account.
      lease.ensureCurrent();

      return OrdersMapper.toEntity(localOrder);
    }
  }

  bool _shouldUseLocalReadFallback(Object error) {
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

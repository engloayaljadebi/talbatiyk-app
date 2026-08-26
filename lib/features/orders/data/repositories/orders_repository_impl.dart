import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/orders_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/local/orders_local_datasource.dart';
import '../datasources/orders_datasource.dart';
import '../mappers/orders_mapper.dart';
import '../models/orders_model.dart';

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
    final CreateOrderModel createModel = OrdersMapper.toCreateModel(request);

    final OrdersDataSource? remote = remoteDataSource;

    if (remote == null) {
      final OrderModel localOrder = await localDataSource.createOrder(
        createModel,
      );

      return OrdersMapper.toEntity(localOrder);
    }

    try {
      final OrderModel remoteOrder = await remote.createOrder(createModel);

      // نجاح الخادم لا ينشئ Outbox؛ نحفظ نسخة السيرفر فقط.
      await localDataSource.saveOrder(remoteOrder);

      return OrdersMapper.toEntity(remoteOrder);
    } catch (error) {
      // لا نحول أخطاء validation أو server responses إلى Offline Orders.
      // الـ fallback مسموح فقط عند فقدان الاتصال فعليًا.
      if (!_isConnectivityFailure(error)) {
        rethrow;
      }

      final OrderModel localOrder = await localDataSource.createOrder(
        createModel,
      );

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

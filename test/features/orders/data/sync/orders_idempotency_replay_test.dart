import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/data/sync/orders_sync_coordinator.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';

void main() {
  test(
    'lost response replays the same idempotency key without duplicating order',
    () async {
      final AppDatabase database = AppDatabase.forTesting(
        NativeDatabase.memory(),
      );

      addTearDown(database.close);

      final OrdersLocalDataSource localDataSource = OrdersLocalDataSource(
        database,
      );

      final _LostResponseThenReplayOrdersDataSource remoteDataSource =
          _LostResponseThenReplayOrdersDataSource();

      final OrdersRepositoryImpl repository = OrdersRepositoryImpl(
        localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final CreateOrderRequest request = CreateOrderRequest(
        notes: 'Lost response order',
        items: const [
          OrderItemEntity(
            productId: 'product-1',
            productName: 'Product 1',
            unitPrice: 100,
            quantity: 2,
            supplierId: 'supplier-1',
            supplierName: 'Supplier 1',
          ),
          OrderItemEntity(
            productId: 'product-2',
            productName: 'Product 2',
            unitPrice: 200,
            quantity: 1,
            supplierId: 'supplier-2',
            supplierName: 'Supplier 2',
          ),
        ],
      );

      /*
       * The fake server commits the first request but deliberately loses
       * the response. The repository therefore observes a connectivity
       * failure and queues the same logical operation locally.
       */
      final OrderEntity queuedOrder = await repository.createOrder(request);

      expect(queuedOrder.id, startsWith('local-order-'));

      expect(remoteDataSource.createRequests, hasLength(1));
      expect(remoteDataSource.serverCreateCount, 1);

      final String firstAttemptKey =
          remoteDataSource.createRequests.single.idempotencyKey;

      expect(firstAttemptKey, isNotEmpty);

      final operationsBeforeReplay = await database
          .select(database.syncOperations)
          .get();

      expect(operationsBeforeReplay, hasLength(1));

      final Map<String, dynamic> queuedPayload =
          jsonDecode(operationsBeforeReplay.single.payloadJson)
              as Map<String, dynamic>;

      expect(queuedPayload['idempotencyKey'], firstAttemptKey);

      /*
       * A later coordinator run represents reconnect/restart replay.
       * The fake server returns its already-created order only when the
       * exact same idempotency key is reused.
       */
      final OrdersSyncCoordinator coordinator = OrdersSyncCoordinator(
        database: database,
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
      );

      await coordinator.syncPendingOrders();

      expect(remoteDataSource.createRequests, hasLength(2));

      final String replayKey =
          remoteDataSource.createRequests[1].idempotencyKey;

      expect(replayKey, firstAttemptKey);

      // A changed key would have produced a second fake server order.
      expect(remoteDataSource.serverCreateCount, 1);

      final List<OrderModel> localOrders = await localDataSource.getOrders();

      expect(localOrders, hasLength(1));
      expect(localOrders.single.id, 'server-order-1');

      expect(
        localOrders.any((OrderModel order) => order.id == queuedOrder.id),
        isFalse,
      );

      expect(
        localOrders.single.items
            .map((OrderItemModel item) => item.supplierId)
            .toSet(),
        <String>{'supplier-1', 'supplier-2'},
      );

      final operationsAfterReplay = await database
          .select(database.syncOperations)
          .get();

      expect(operationsAfterReplay, isEmpty);
    },
  );
}

class _LostResponseThenReplayOrdersDataSource implements OrdersDataSource {
  final List<CreateOrderModel> createRequests = <CreateOrderModel>[];

  final Map<String, OrderModel> _serverOrdersByIdempotencyKey =
      <String, OrderModel>{};

  int serverCreateCount = 0;

  bool _dropFirstResponse = true;

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    createRequests.add(request);

    final String idempotencyKey = request.idempotencyKey.trim();

    if (idempotencyKey.isEmpty) {
      throw StateError('Fake server requires an idempotency key.');
    }

    final OrderModel? existingOrder =
        _serverOrdersByIdempotencyKey[idempotencyKey];

    if (existingOrder != null) {
      return existingOrder;
    }

    serverCreateCount++;

    final OrderModel serverOrder = OrderModel(
      id: 'server-order-$serverCreateCount',
      status: 'pending',
      notes: request.notes,
      createdAt: DateTime.utc(2026, 8, 26, 6),
      items: request.items,
    );

    _serverOrdersByIdempotencyKey[idempotencyKey] = serverOrder;

    if (_dropFirstResponse) {
      _dropFirstResponse = false;

      throw DioException(
        requestOptions: RequestOptions(path: '/orders'),
        type: DioExceptionType.connectionError,
        message: 'response lost after server commit',
      );
    }

    return serverOrder;
  }

  @override
  Future<List<OrderModel>> getOrders() {
    throw UnsupportedError('Not used by this test.');
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    throw UnsupportedError('Not used by this test.');
  }
}

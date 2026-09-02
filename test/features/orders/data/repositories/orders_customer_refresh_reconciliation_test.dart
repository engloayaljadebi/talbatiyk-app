import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';

void main() {
  group('customer orders authoritative refresh', () {
    test(
      'replaces stale server snapshot but preserves pending local create',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);

        final local = OrdersLocalDataSource(database);

        await local.saveOrder(
          _serverOrder(
            id: 'server-order-1',
            aggregateStatus: 'pending_responses',
            createdAt: DateTime.utc(2026, 8, 30),
          ),
        );

        await local.saveOrder(
          _serverOrder(
            id: 'stale-server-order',
            aggregateStatus: 'pending_responses',
            createdAt: DateTime.utc(2026, 8, 29),
          ),
        );

        final pendingLocal = await local.createOrder(
          CreateOrderModel(
            idempotencyKey: '11111111-1111-4111-8111-111111111111',
            supplierIds: const ['supplier-1'],
            items: const [
              OrderItemModel(
                productId: 'product-local',
                productName: 'Pending product',
                unitPrice: 10,
                quantity: 1,
                supplierId: 'supplier-1',
                supplierName: 'Supplier 1',
              ),
            ],
          ),
        );

        final remote = _FakeRemoteOrdersDataSource(
          orders: [
            _serverOrder(
              id: 'server-order-1',
              aggregateStatus: 'responses_received',
              createdAt: DateTime.utc(2026, 8, 30),
            ),
          ],
        );

        final repository = OrdersRepositoryImpl(
          local,
          remoteDataSource: remote,
        );

        final result = await repository.getOrders();
        final persisted = await local.getOrders();

        expect(result.map((order) => order.id).toSet(), {
          'server-order-1',
          pendingLocal.id,
        });

        expect(persisted.map((order) => order.id).toSet(), {
          'server-order-1',
          pendingLocal.id,
        });

        expect(
          persisted
              .singleWhere((order) => order.id == 'server-order-1')
              .aggregateStatus,
          'responses_received',
        );

        expect(
          persisted.any((order) => order.id == 'stale-server-order'),
          isFalse,
        );

        final outbox = await database.select(database.syncOperations).get();

        expect(outbox, hasLength(1));
        expect(outbox.single.entityId, pendingLocal.id);
        expect(outbox.single.operation, 'create');
      },
    );

    test('uses Drift when GET orders fails due to connectivity', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final local = OrdersLocalDataSource(database);

      await local.saveOrder(
        _serverOrder(
          id: 'cached-order',
          aggregateStatus: 'pending_responses',
          createdAt: DateTime.utc(2026, 8, 30),
        ),
      );

      final requestOptions = RequestOptions(path: '/orders');

      final remoteError = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
        error: const SocketException('offline'),
      );

      final repository = OrdersRepositoryImpl(
        local,
        remoteDataSource: _FakeRemoteOrdersDataSource(getError: remoteError),
      );

      final orders = await repository.getOrders();

      expect(orders, hasLength(1));
      expect(orders.single.id, 'cached-order');
    });

    test(
      'does not hide authentication failures behind cached orders',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);

        final local = OrdersLocalDataSource(database);

        await local.saveOrder(
          _serverOrder(
            id: 'cached-order',
            aggregateStatus: 'pending_responses',
            createdAt: DateTime.utc(2026, 8, 30),
          ),
        );

        final requestOptions = RequestOptions(path: '/orders');

        final remoteError = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.badResponse,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 401,
          ),
        );

        final repository = OrdersRepositoryImpl(
          local,
          remoteDataSource: _FakeRemoteOrdersDataSource(getError: remoteError),
        );

        await expectLater(repository.getOrders(), throwsA(same(remoteError)));

        final persisted = await local.getOrders();

        expect(persisted, hasLength(1));
        expect(persisted.single.id, 'cached-order');
      },
    );
  });
}

OrderModel _serverOrder({
  required String id,
  required String aggregateStatus,
  required DateTime createdAt,
}) {
  return OrderModel(
    id: id,
    status: 'pending',
    aggregateStatus: aggregateStatus,
    notes: '',
    createdAt: createdAt,
    items: const [
      OrderItemModel(
        productId: 'product-1',
        productName: 'Product 1',
        unitPrice: 100,
        quantity: 1,
        supplierId: 'supplier-1',
        supplierName: 'Supplier 1',
      ),
    ],
  );
}

final class _FakeRemoteOrdersDataSource implements OrdersDataSource {
  _FakeRemoteOrdersDataSource({
    this.orders = const <OrderModel>[],
    this.getError,
  });

  final List<OrderModel> orders;
  final Object? getError;

  @override
  Future<List<OrderModel>> getOrders() async {
    final Object? error = getError;

    if (error != null) {
      throw error;
    }

    return orders;
  }

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) {
    throw UnsupportedError('Not used by customer refresh tests.');
  }
}

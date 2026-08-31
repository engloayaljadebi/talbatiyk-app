import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';

void main() {
  test(
    'persists local order and Outbox before first remote attempt then reconciles success',
    () async {
      final AppDatabase database = AppDatabase.forTesting(
        NativeDatabase.memory(),
      );

      addTearDown(database.close);

      final OrdersLocalDataSource localDataSource = OrdersLocalDataSource(
        database,
      );

      late final _InspectingRemoteOrdersDataSource remoteDataSource;

      remoteDataSource = _InspectingRemoteOrdersDataSource(
        createdOrder: OrderModel(
          id: 'server-order-1',
          status: 'pending',
          createdAt: DateTime.utc(2026, 8, 28),
          notes: 'Local-first order',
          items: const [
            OrderItemModel(
              productId: 'product-1',
              productName: 'Server product',
              unitPrice: 125.50,
              quantity: 2,
              supplierId: 'supplier-1',
              supplierName: 'Server supplier',
            ),
          ],
        ),
        beforeCreate: (CreateOrderModel request) async {
          /*
           * This assertion is the Local-First boundary:
           * durable local state and Outbox must exist before network I/O.
           */
          final List<OrderModel> localOrders = await localDataSource
              .getOrders();

          final operations = await database
              .select(database.syncOperations)
              .get();

          expect(localOrders, hasLength(1));
          expect(operations, hasLength(1));

          final OrderModel localOrder = localOrders.single;
          final operation = operations.single;

          expect(localOrder.id, startsWith('local-order-'));
          expect(operation.entityId, localOrder.id);
          expect(operation.id, 'order:create:${localOrder.id}');

          final Map<String, dynamic> payload =
              jsonDecode(operation.payloadJson) as Map<String, dynamic>;

          expect(request.idempotencyKey, isNotEmpty);
          expect(payload['idempotencyKey'], request.idempotencyKey);
        },
      );

      final OrdersRepositoryImpl repository = OrdersRepositoryImpl(
        localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final OrderEntity created = await repository.createOrder(
        CreateOrderRequest(
          notes: 'Local-first order',
          items: const [
            OrderItemEntity(
              productId: 'product-1',
              productName: 'Observed product',
              unitPrice: 100,
              quantity: 2,
              supplierId: 'supplier-1',
              supplierName: 'Observed supplier',
            ),
          ],
        ),
      );

      expect(created.id, 'server-order-1');

      final List<OrderModel> persistedOrders = await localDataSource
          .getOrders();

      final remainingOperations = await database
          .select(database.syncOperations)
          .get();

      final persistedItemRows = await database
          .select(database.orderItemRecords)
          .get();
      expect(persistedOrders, hasLength(1));
      expect(persistedOrders.single.id, 'server-order-1');
      expect(persistedOrders.single.items.single.productName, 'Server product');
      expect(persistedOrders.single.items.single.unitPrice, 125.50);
      expect(persistedItemRows, hasLength(1));
      expect(persistedItemRows.single.orderId, 'server-order-1');
      expect(remainingOperations, isEmpty);
    },
  );
}

final class _InspectingRemoteOrdersDataSource implements OrdersDataSource {
  _InspectingRemoteOrdersDataSource({
    required this.createdOrder,
    required this.beforeCreate,
  });

  final OrderModel createdOrder;
  final Future<void> Function(CreateOrderModel request) beforeCreate;

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    await beforeCreate(request);

    return createdOrder;
  }

  @override
  Future<List<OrderModel>> getOrders() {
    throw UnsupportedError('Not used by this test.');
  }
}

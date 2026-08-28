import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';

void main() {
  group('OrdersRepositoryImpl', () {
    test('creates remotely and persists the server order locally', () async {
      final AppDatabase database = AppDatabase.forTesting(
        NativeDatabase.memory(),
      );

      addTearDown(database.close);

      final localDataSource = OrdersLocalDataSource(database);

      final serverCreatedAt = DateTime.utc(2026, 8, 24, 12);

      final remoteDataSource = _FakeRemoteOrdersDataSource(
        createdOrder: OrderModel(
          id: 'server-order-1',
          status: 'pending',
          createdAt: serverCreatedAt,
          notes: 'Remote order',
          items: const [
            OrderItemModel(
              productId: 'product-1',
              productName: 'Product 1',
              unitPrice: 100,
              quantity: 2,
              supplierId: 'supplier-1',
              supplierName: 'Supplier 1',
            ),
            OrderItemModel(
              productId: 'product-2',
              productName: 'Product 2',
              unitPrice: 200,
              quantity: 1,
              supplierId: 'supplier-2',
              supplierName: 'Supplier 2',
            ),
          ],
        ),
      );

      final repository = OrdersRepositoryImpl(
        localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final request = CreateOrderRequest(
        notes: 'Remote order',
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

      final OrderEntity created = await repository.createOrder(request);

      expect(remoteDataSource.createRequest, isNotNull);

      expect(created.id, 'server-order-1');
      expect(created.status, OrderStatus.pending);
      expect(created.items, hasLength(2));

      final List<OrderEntity> localOrders = await repository.getOrders();

      expect(localOrders, hasLength(1));
      expect(localOrders.single.id, 'server-order-1');
      expect(localOrders.single.createdAt, serverCreatedAt);

      expect(
        localOrders.single.items.map((item) => item.supplierId).toSet(),
        <String>{'supplier-1', 'supplier-2'},
      );

      final syncOperations = await database
          .select(database.syncOperations)
          .get();

      // النجاح المباشر مع السيرفر لا يجب أن يترك عملية Outbox.
      expect(syncOperations, isEmpty);
    });

    test(
      'queues a local order when remote creation fails due to connectivity',
      () async {
        final AppDatabase database = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );

        addTearDown(database.close);

        final localDataSource = OrdersLocalDataSource(database);

        final remoteDataSource = _FakeRemoteOrdersDataSource(
          createError: DioException(
            requestOptions: RequestOptions(path: '/orders'),
            type: DioExceptionType.connectionError,
            message: 'network unavailable',
          ),
        );

        final repository = OrdersRepositoryImpl(
          localDataSource,
          remoteDataSource: remoteDataSource,
        );

        final request = CreateOrderRequest(
          notes: 'Offline order',
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

        final OrderEntity created = await repository.createOrder(request);

        final localOrders = await localDataSource.getOrders();

        final syncOperations = await database
            .select(database.syncOperations)
            .get();

        expect(created.id, startsWith('local-order-'));
        expect(created.status, OrderStatus.pending);
        expect(created.items, hasLength(2));

        expect(localOrders, hasLength(1));
        expect(localOrders.single.id, created.id);

        expect(syncOperations, hasLength(1));

        final operation = syncOperations.single;

        expect(operation.id, 'order:create:${created.id}');
        expect(operation.entityType, 'order');
        expect(operation.entityId, created.id);
        expect(operation.operation, 'create');
        expect(operation.attempts, 0);
        expect(operation.lastError, isNull);

        final payload =
            jsonDecode(operation.payloadJson) as Map<String, dynamic>;
        final String firstAttemptKey =
            remoteDataSource.createRequest!.idempotencyKey;

        expect(firstAttemptKey, isNotEmpty);
        expect(payload['idempotencyKey'], firstAttemptKey);

        expect(payload['notes'], 'Offline order');

        final items = payload['items'] as List<dynamic>;

        expect(items, hasLength(2));

        expect(
          items
              .map((item) => (item as Map<String, dynamic>)['supplierId'])
              .toSet(),
          <String>{'supplier-1', 'supplier-2'},
        );
      },
    );

    test('keeps local order queued when server returns HTTP 503', () async {
      final AppDatabase database = AppDatabase.forTesting(
        NativeDatabase.memory(),
      );

      addTearDown(database.close);

      final localDataSource = OrdersLocalDataSource(database);
      final requestOptions = RequestOptions(path: '/orders');

      final remoteError = DioException(
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 503,
          data: <String, dynamic>{'message': 'Service unavailable'},
        ),
        type: DioExceptionType.badResponse,
        message: 'Service unavailable',
      );

      final remoteDataSource = _FakeRemoteOrdersDataSource(
        createError: remoteError,
      );

      final repository = OrdersRepositoryImpl(
        localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final OrderEntity created = await repository.createOrder(
        CreateOrderRequest(
          items: const [
            OrderItemEntity(
              productId: 'product-1',
              productName: 'Product 1',
              unitPrice: 100,
              quantity: 1,
              supplierId: 'supplier-1',
              supplierName: 'Supplier 1',
            ),
          ],
        ),
      );

      final localOrders = await localDataSource.getOrders();
      final syncOperations = await database
          .select(database.syncOperations)
          .get();

      expect(created.id, startsWith('local-order-'));
      expect(localOrders, hasLength(1));
      expect(localOrders.single.id, created.id);
      expect(syncOperations, hasLength(1));

      final payload =
          jsonDecode(syncOperations.single.payloadJson) as Map<String, dynamic>;

      expect(remoteDataSource.createRequest, isNotNull);
      expect(
        payload['idempotencyKey'],
        remoteDataSource.createRequest!.idempotencyKey,
      );
    });
    test('does not turn HTTP 422 into an offline order', () async {
      final AppDatabase database = AppDatabase.forTesting(
        NativeDatabase.memory(),
      );

      addTearDown(database.close);

      final localDataSource = OrdersLocalDataSource(database);

      final requestOptions = RequestOptions(path: '/orders');

      final remoteError = DioException(
        requestOptions: requestOptions,
        response: Response<dynamic>(
          requestOptions: requestOptions,
          statusCode: 422,
          data: <String, dynamic>{'message': 'Validation failed'},
        ),
        type: DioExceptionType.badResponse,
        message: 'Validation failed',
      );

      final remoteDataSource = _FakeRemoteOrdersDataSource(
        createError: remoteError,
      );

      final repository = OrdersRepositoryImpl(
        localDataSource,
        remoteDataSource: remoteDataSource,
      );

      final request = CreateOrderRequest(
        items: const [
          OrderItemEntity(
            productId: 'product-1',
            productName: 'Product 1',
            unitPrice: 100,
            quantity: 1,
            supplierId: 'supplier-1',
            supplierName: 'Supplier 1',
          ),
        ],
      );

      await expectLater(
        repository.createOrder(request),
        throwsA(same(remoteError)),
      );

      final localOrders = await localDataSource.getOrders();

      final syncOperations = await database
          .select(database.syncOperations)
          .get();

      // HTTP 422 ليس فقدان اتصال، لذلك لا ننشئ Offline Order.
      expect(localOrders, isEmpty);
      expect(syncOperations, isEmpty);
    });

    test(
      'does not hide programming failures and keeps durable state',
      () async {
        final AppDatabase database = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );

        addTearDown(database.close);

        final localDataSource = OrdersLocalDataSource(database);

        final remoteError = StateError('Remote create failed');

        final remoteDataSource = _FakeRemoteOrdersDataSource(
          createError: remoteError,
        );

        final repository = OrdersRepositoryImpl(
          localDataSource,
          remoteDataSource: remoteDataSource,
        );

        final request = CreateOrderRequest(
          items: const [
            OrderItemEntity(
              productId: 'product-1',
              productName: 'Product 1',
              unitPrice: 100,
              quantity: 1,
              supplierId: 'supplier-1',
              supplierName: 'Supplier 1',
            ),
          ],
        );

        await expectLater(
          repository.createOrder(request),
          throwsA(same(remoteError)),
        );

        final localOrders = await localDataSource.getOrders();

        final syncOperations = await database
            .select(database.syncOperations)
            .get();

        expect(localOrders, hasLength(1));
        expect(localOrders.single.id, startsWith('local-order-'));

        expect(syncOperations, hasLength(1));
        expect(syncOperations.single.entityId, localOrders.single.id);

        final payload =
            jsonDecode(syncOperations.single.payloadJson)
                as Map<String, dynamic>;

        expect(remoteDataSource.createRequest, isNotNull);
        expect(
          payload['idempotencyKey'],
          remoteDataSource.createRequest!.idempotencyKey,
        );
      },
    );

    test(
      'supports local-only creation when no remote source is configured',
      () async {
        final AppDatabase database = AppDatabase.forTesting(
          NativeDatabase.memory(),
        );

        addTearDown(database.close);

        final localDataSource = OrdersLocalDataSource(database);

        final repository = OrdersRepositoryImpl(localDataSource);

        final request = CreateOrderRequest(
          items: const [
            OrderItemEntity(
              productId: 'product-1',
              productName: 'Product 1',
              unitPrice: 4500,
              quantity: 2,
              supplierId: 'supplier-1',
              supplierName: 'Supplier 1',
            ),
          ],
        );

        final OrderEntity created = await repository.createOrder(request);

        final List<OrderEntity> orders = await repository.getOrders();

        final syncOperations = await database
            .select(database.syncOperations)
            .get();

        expect(created.status, OrderStatus.pending);
        expect(created.totalQuantity, 2);
        expect(created.totalPrice, 9000);

        expect(created.id, startsWith('local-order-'));

        expect(orders, hasLength(1));
        expect(orders.single.id, created.id);

        // local-only يعني أن الطلب يحتاج مزامنة لاحقًا.
        expect(syncOperations, hasLength(1));

        final operation = syncOperations.single;

        expect(operation.entityType, 'order');
        expect(operation.operation, 'create');
        expect(operation.entityId, created.id);
      },
    );
  });
}

class _FakeRemoteOrdersDataSource implements OrdersDataSource {
  _FakeRemoteOrdersDataSource({this.createdOrder, this.createError});

  final OrderModel? createdOrder;
  final Object? createError;

  CreateOrderModel? createRequest;

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    createRequest = request;

    final Object? error = createError;

    if (error != null) {
      throw error;
    }

    final OrderModel? order = createdOrder;

    if (order == null) {
      throw StateError('Fake remote order was not configured.');
    }

    return order;
  }

  @override
  Future<List<OrderModel>> getOrders() async {
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

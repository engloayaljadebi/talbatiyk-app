import 'package:dio/dio.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/sync/orders_sync_coordinator.dart';

void main() {
  group('OrdersSyncCoordinator', () {
    test(
      'replays pending create and replaces local order with server order',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final local = OrdersLocalDataSource(database);

        final localOrder = await local.createOrder(
          CreateOrderModel(
            supplierIds: const ['supplier-1'],
            notes: 'Offline',
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

        final remote = _FakeOrdersDataSource(
          createdOrder: OrderModel(
            id: 'server-order-1',
            status: 'pending',
            notes: 'Offline',
            createdAt: DateTime.utc(2026, 8, 26),
            items: localOrder.items,
          ),
        );

        final coordinator = OrdersSyncCoordinator(
          database: database,
          localDataSource: local,
          remoteDataSource: remote,
        );

        await coordinator.syncPendingOrders();

        final orders = await local.getOrders();
        final operations = await database.select(database.syncOperations).get();

        expect(remote.createCalls, 1);

        expect(orders, hasLength(1));
        expect(orders.single.id, 'server-order-1');

        expect(
          orders.single.items.map((item) => item.supplierId).toSet(),
          <String>{'supplier-1', 'supplier-2'},
        );

        expect(orders.any((order) => order.id == localOrder.id), isFalse);

        expect(operations, isEmpty);
      },
    );

    test(
      'keeps Outbox operation and schedules retry when replay fails',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final local = OrdersLocalDataSource(database);

        final localOrder = await local.createOrder(
          CreateOrderModel(
            supplierIds: const ['supplier-1'],
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
          ),
        );

        final remote = _FakeOrdersDataSource(
          createError: StateError('network unavailable'),
        );

        final coordinator = OrdersSyncCoordinator(
          database: database,
          localDataSource: local,
          remoteDataSource: remote,
        );

        await coordinator.syncPendingOrders();

        final orders = await local.getOrders();
        final operations = await database.select(database.syncOperations).get();

        expect(remote.createCalls, 1);

        expect(orders, hasLength(1));
        expect(orders.single.id, localOrder.id);

        expect(operations, hasLength(1));
        expect(operations.single.entityId, localOrder.id);
        expect(operations.single.attempts, 1);
        expect(operations.single.lastError, isNotNull);
        expect(operations.single.nextAttemptAt, isNotNull);
      },
    );
    test(
      'dead-letters malformed Outbox payload without retrying it again',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final local = OrdersLocalDataSource(database);

        final localOrder = await local.createOrder(
          CreateOrderModel(
            supplierIds: const ['supplier-1'],
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
          ),
        );

        await (database.update(
          database.syncOperations,
        )..where((table) => table.entityId.equals(localOrder.id))).write(
          const SyncOperationsCompanion(payloadJson: Value('{invalid-json')),
        );

        final remote = _FakeOrdersDataSource(
          createError: StateError('must not be called'),
        );

        final coordinator = OrdersSyncCoordinator(
          database: database,
          localDataSource: local,
          remoteDataSource: remote,
        );

        await coordinator.syncPendingOrders();

        final firstOperation = await database
            .select(database.syncOperations)
            .getSingle();

        expect(remote.createCalls, 0);
        expect(firstOperation.status, SyncOperationStatuses.permanentFailure);
        expect(firstOperation.attempts, 1);
        expect(firstOperation.lastError, isNotNull);
        expect(firstOperation.nextAttemptAt, isNull);

        // التشغيل الثاني يجب ألا يلمس permanent failure أصلًا.
        await coordinator.syncPendingOrders();

        final secondOperation = await database
            .select(database.syncOperations)
            .getSingle();

        expect(remote.createCalls, 0);
        expect(secondOperation.attempts, 1);
      },
    );
    test('dead-letters HTTP 422 instead of retrying forever', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final local = OrdersLocalDataSource(database);

      final localOrder = await local.createOrder(
        CreateOrderModel(
          supplierIds: const ['supplier-1'],
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
        ),
      );

      final requestOptions = RequestOptions(path: '/orders');

      final remote = _FakeOrdersDataSource(
        createError: DioException(
          requestOptions: requestOptions,
          response: Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: 422,
            data: <String, dynamic>{'message': 'Validation failed'},
          ),
          type: DioExceptionType.badResponse,
          message: 'Validation failed',
        ),
      );

      final coordinator = OrdersSyncCoordinator(
        database: database,
        localDataSource: local,
        remoteDataSource: remote,
      );

      await coordinator.syncPendingOrders();

      final firstOperation = await database
          .select(database.syncOperations)
          .getSingle();

      final orders = await local.getOrders();

      expect(remote.createCalls, 1);

      // في background sync لا نحذف durable state عند الرفض النهائي.
      // نحفظ العملية كـdead-letter حتى لا يتحول فشل المزامنة إلى Data Loss.
      expect(orders, hasLength(1));
      expect(orders.single.id, localOrder.id);

      expect(firstOperation.status, SyncOperationStatuses.permanentFailure);
      expect(firstOperation.attempts, 1);
      expect(firstOperation.lastError, isNotNull);
      expect(firstOperation.nextAttemptAt, isNull);

      await coordinator.syncPendingOrders();

      final secondOperation = await database
          .select(database.syncOperations)
          .getSingle();

      // permanent_failure لا يدخل قائمة العمليات المؤهلة للمزامنة مرة أخرى.
      expect(remote.createCalls, 1);
      expect(secondOperation.attempts, 1);
    });
    test('keeps HTTP 503 retryable with backoff', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final local = OrdersLocalDataSource(database);

      final localOrder = await local.createOrder(
        CreateOrderModel(
          supplierIds: const ['supplier-1'],
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
        ),
      );

      final requestOptions = RequestOptions(path: '/orders');

      final remote = _FakeOrdersDataSource(
        createError: DioException(
          requestOptions: requestOptions,
          response: Response<dynamic>(
            requestOptions: requestOptions,
            statusCode: 503,
            data: <String, dynamic>{'message': 'Service unavailable'},
          ),
          type: DioExceptionType.badResponse,
          message: 'Service unavailable',
        ),
      );

      final coordinator = OrdersSyncCoordinator(
        database: database,
        localDataSource: local,
        remoteDataSource: remote,
      );

      await coordinator.syncPendingOrders();

      final operation = await database
          .select(database.syncOperations)
          .getSingle();

      expect(remote.createCalls, 1);
      expect(operation.entityId, localOrder.id);
      expect(operation.status, SyncOperationStatuses.retrying);
      expect(operation.attempts, 1);
      expect(operation.lastError, isNotNull);
      expect(operation.nextAttemptAt, isNotNull);

      // المحاولة الفورية الثانية لا تتم لأن backoff لم ينته بعد.
      await coordinator.syncPendingOrders();

      expect(remote.createCalls, 1);
    });
    test('does not replay an operation before nextAttemptAt', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final local = OrdersLocalDataSource(database);

      final localOrder = await local.createOrder(
        CreateOrderModel(
          supplierIds: const ['supplier-1'],
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
        ),
      );

      await (database.update(
        database.syncOperations,
      )..where((table) => table.entityId.equals(localOrder.id))).write(
        SyncOperationsCompanion(
          nextAttemptAt: Value(
            DateTime.now().toUtc().add(const Duration(hours: 1)),
          ),
        ),
      );

      final remote = _FakeOrdersDataSource(
        createError: StateError('must not be called'),
      );

      final coordinator = OrdersSyncCoordinator(
        database: database,
        localDataSource: local,
        remoteDataSource: remote,
      );

      await coordinator.syncPendingOrders();

      expect(remote.createCalls, 0);

      final operations = await database.select(database.syncOperations).get();

      expect(operations, hasLength(1));
      expect(operations.single.attempts, 0);
    });
  });
}

class _FakeOrdersDataSource implements OrdersDataSource {
  _FakeOrdersDataSource({this.createdOrder, this.createError});

  final OrderModel? createdOrder;
  final Object? createError;

  int createCalls = 0;

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    createCalls++;

    final Object? error = createError;

    if (error != null) {
      throw error;
    }

    final OrderModel? order = createdOrder;

    if (order == null) {
      throw StateError('No fake remote order configured.');
    }

    return order;
  }

  @override
  Future<List<OrderModel>> getOrders() {
    throw UnsupportedError('Not used.');
  }
}

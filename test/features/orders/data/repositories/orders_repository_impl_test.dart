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

      expect(localOrders.single.items.map((item) => item.supplierId).toSet(), {
        'supplier-1',
        'supplier-2',
      });
    });

    test('does not create a local order when remote creation fails', () async {
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

      expect(localOrders, isEmpty);
    });

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

        final created = await repository.createOrder(request);

        final orders = await repository.getOrders();

        expect(created.status, OrderStatus.pending);
        expect(created.totalQuantity, 2);
        expect(created.totalPrice, 9000);

        expect(created.id, startsWith('local-order-'));

        expect(orders, hasLength(1));
        expect(orders.single.id, created.id);
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

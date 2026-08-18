import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  group('OrdersLocalDataSource', () {
    late OrdersLocalDataSource dataSource;
    late AppDatabase database;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());

      dataSource = OrdersLocalDataSource(database);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'persists a multi-supplier order across data source instances',
      () async {
        final CreateOrderModel request = CreateOrderModel(
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
          notes: 'Multi supplier order',
        );

        final OrderModel created = await dataSource.createOrder(request);

        final OrdersLocalDataSource reloadedDataSource = OrdersLocalDataSource(
          database,
        );

        final List<OrderModel> orders = await reloadedDataSource.getOrders();

        expect(orders, hasLength(1));

        final OrderModel persisted = orders.single;

        expect(persisted.id, created.id);
        expect(persisted.status, 'pending');
        expect(persisted.notes, 'Multi supplier order');
        expect(persisted.items, hasLength(2));

        expect(persisted.items.map((item) => item.supplierId).toSet(), {
          'supplier-1',
          'supplier-2',
        });

        expect(persisted.items[0].supplierName, 'Supplier 1');

        expect(persisted.items[1].supplierName, 'Supplier 2');
      },
    );

    test(
      'creates one order containing items from multiple suppliers',
      () async {
        final CreateOrderModel request = CreateOrderModel(
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
        );

        final OrderModel created = await dataSource.createOrder(request);

        expect(created.items, hasLength(2));

        expect(created.items[0].supplierId, 'supplier-1');

        expect(created.items[0].supplierName, 'Supplier 1');

        expect(created.items[1].supplierId, 'supplier-2');

        expect(created.items[1].supplierName, 'Supplier 2');

        expect(created.items.map((item) => item.supplierId).toSet(), {
          'supplier-1',
          'supplier-2',
        });
      },
    );

    test('creates an order and preserves supplier data per item', () async {
      final CreateOrderModel request = CreateOrderModel(
        items: const [
          OrderItemModel(
            supplierId: 'supplier-1',
            supplierName: 'مؤسسة الأمل',
            productId: 'product-1',
            productName: 'شاحن سريع',
            unitPrice: 4500,
            quantity: 2,
          ),
        ],
      );

      final OrderModel created = await dataSource.createOrder(request);

      final List<OrderModel> orders = await dataSource.getOrders();

      expect(created.id, isNotEmpty);
      expect(created.id, startsWith('local-order-'));

      expect(created.status, 'pending');
      expect(created.items, hasLength(1));

      expect(created.items.single.supplierId, 'supplier-1');

      expect(created.items.single.supplierName, 'مؤسسة الأمل');

      expect(orders, hasLength(1));
      expect(orders.single.id, created.id);

      expect(orders.single.items.single.quantity, 2);

      expect(orders.single.items.single.supplierId, 'supplier-1');

      expect(orders.single.items.single.supplierName, 'مؤسسة الأمل');
    });

    test('updates order status and keeps supplier data per item', () async {
      final CreateOrderModel request = CreateOrderModel(
        items: const [
          OrderItemModel(
            supplierId: 'supplier-1',
            supplierName: 'مؤسسة الأمل',
            productId: 'product-1',
            productName: 'شاحن سريع',
            unitPrice: 4500,
            quantity: 1,
          ),
        ],
      );

      final OrderModel created = await dataSource.createOrder(request);

      final OrderModel updated = await dataSource.updateOrderStatus(
        orderId: created.id,
        status: 'confirmed',
      );

      final List<OrderModel> orders = await dataSource.getOrders();

      expect(updated.status, 'confirmed');

      expect(updated.items.single.supplierId, 'supplier-1');

      expect(updated.items.single.supplierName, 'مؤسسة الأمل');

      expect(orders.single.status, 'confirmed');

      expect(orders.single.items.single.supplierId, 'supplier-1');

      expect(orders.single.items.single.supplierName, 'مؤسسة الأمل');
    });

    test('throws when updating an order that does not exist', () async {
      expect(
        () => dataSource.updateOrderStatus(
          orderId: 'missing-order',
          status: 'confirmed',
        ),
        throwsA(isA<StateError>()),
      );
    });
  });
}

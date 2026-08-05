import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  group('OrdersLocalDataSource', () {
    late OrdersLocalDataSource dataSource;

    setUp(() {
      dataSource = OrdersLocalDataSource();
    });

    test('creates an order and preserves supplier data', () async {
      final CreateOrderModel request = CreateOrderModel(
        supplier: const OrderSupplierModel(
          id: 'supplier-1',
          name: 'مؤسسة الأمل',
        ),
        items: const [
          OrderItemModel(
            productId: 'product-1',
            productName: 'شاحن سريع',
            unitPrice: 4500,
            quantity: 2,
          ),
        ],
      );

      final OrderModel created = await dataSource.createOrder(request);

      final List<OrderModel> orders = await dataSource.getOrders();

      expect(created.id, 'local-order-1');
      expect(created.status, 'pending');
      expect(created.supplier, isNotNull);
      expect(created.supplier?.id, 'supplier-1');
      expect(created.supplier?.name, 'مؤسسة الأمل');

      expect(orders, hasLength(1));
      expect(orders.single.id, created.id);
      expect(orders.single.items.single.quantity, 2);
      expect(orders.single.supplier?.id, 'supplier-1');
    });

    test('updates order status and keeps supplier data', () async {
      final CreateOrderModel request = CreateOrderModel(
        supplier: const OrderSupplierModel(
          id: 'supplier-1',
          name: 'مؤسسة الأمل',
        ),
        items: const [
          OrderItemModel(
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
      expect(updated.supplier?.id, 'supplier-1');
      expect(updated.supplier?.name, 'مؤسسة الأمل');

      expect(orders.single.status, 'confirmed');
      expect(orders.single.supplier?.name, 'مؤسسة الأمل');
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

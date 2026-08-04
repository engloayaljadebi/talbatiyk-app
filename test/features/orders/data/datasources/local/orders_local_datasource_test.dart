import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  test('creates an order and keeps it in the local data source', () async {
    final dataSource = OrdersLocalDataSource();
    final request = CreateOrderModel(
      items: const [
        OrderItemModel(
          productId: 'product-1',
          productName: 'شاحن سريع',
          unitPrice: 4500,
          quantity: 2,
        ),
      ],
    );

    final created = await dataSource.createOrder(request);
    final orders = await dataSource.getOrders();

    expect(created.id, 'local-order-1');
    expect(created.status, 'pending');
    expect(orders.single.id, created.id);
    expect(orders.single.items.single.quantity, 2);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';

void main() {
  test('creates and maps an order through the repository contract', () async {
    final repository = OrdersRepositoryImpl(OrdersLocalDataSource());
    final request = CreateOrderRequest(
      items: const [
        OrderItemEntity(
          productId: 'product-1',
          productName: 'شاحن سريع',
          unitPrice: 4500,
          quantity: 2,
        ),
      ],
    );

    final created = await repository.createOrder(request);
    final orders = await repository.getOrders();

    expect(created.status, OrderStatus.pending);
    expect(created.totalQuantity, 2);
    expect(created.totalPrice, 9000);
    expect(orders.single.id, created.id);
  });
}

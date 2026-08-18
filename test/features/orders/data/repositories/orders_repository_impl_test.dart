import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';

void main() {
  test('creates and maps an order through the repository contract', () async {
    final AppDatabase database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    addTearDown(() async {
      await database.close();
    });

    final OrdersLocalDataSource localDataSource = OrdersLocalDataSource(
      database,
    );

    final OrdersRepositoryImpl repository = OrdersRepositoryImpl(
      localDataSource,
    );

    final CreateOrderRequest request = CreateOrderRequest(
      items: const [
        OrderItemEntity(
          productId: 'product-1',
          productName: 'شاحن سريع',
          unitPrice: 4500,
          quantity: 2,
          supplierId: 'supplier-1',
          supplierName: 'Supplier 1',
        ),
      ],
    );

    final OrderEntity created = await repository.createOrder(request);

    final List<OrderEntity> orders = await repository.getOrders();

    expect(created.status, OrderStatus.pending);

    expect(created.totalQuantity, 2);

    expect(created.totalPrice, 9000);

    expect(created.items.single.supplierId, 'supplier-1');

    expect(created.items.single.supplierName, 'Supplier 1');

    expect(orders.single.id, created.id);
  });
}

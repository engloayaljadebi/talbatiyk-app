import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';
import 'package:talbatiyk/features/orders/domain/usecases/orders_usecase.dart';
import 'package:talbatiyk/features/orders/presentation/controllers/orders_controller.dart';

void main() {
  late AppDatabase database;
  late OrdersLocalDataSource dataSource;
  late OrdersController controller;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());

    dataSource = OrdersLocalDataSource(database);

    controller = OrdersController(
      OrdersUseCase(OrdersRepositoryImpl(dataSource)),
      autoLoad: false,
    );
  });

  tearDown(() async {
    controller.dispose();
    await database.close();
  });

  test('creates an order and adds it to state', () async {
    final CreateOrderRequest request = CreateOrderRequest(
      supplierIds: const ['supplier-1'],
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

    final OrderEntity? created = await controller.createOrder(request);

    expect(created, isNotNull);
    expect(controller.state.isSubmitting, isFalse);

    expect(controller.state.orders.single.id, created!.id);

    expect(controller.state.lastCreatedOrder?.id, created.id);

    expect(created.items.single.supplierId, 'supplier-1');

    expect(created.items.single.supplierName, 'Supplier 1');
  });

  test('loads orders created through the same data source', () async {
    final CreateOrderRequest request = CreateOrderRequest(
      supplierIds: const ['supplier-1'],
      items: const [
        OrderItemEntity(
          productId: 'product-1',
          productName: 'شاحن سريع',
          unitPrice: 4500,
          quantity: 1,
          supplierId: 'supplier-1',
          supplierName: 'Supplier 1',
        ),
      ],
    );

    await controller.createOrder(request);
    await controller.loadOrders();

    expect(controller.state.orders, hasLength(1));

    expect(controller.state.errorMessage, isNull);

    expect(
      controller.state.orders.single.items.single.supplierId,
      'supplier-1',
    );

    expect(
      controller.state.orders.single.items.single.supplierName,
      'Supplier 1',
    );
  });
}

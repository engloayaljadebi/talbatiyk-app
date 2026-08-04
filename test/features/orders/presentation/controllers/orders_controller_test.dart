import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';
import 'package:talbatiyk/features/orders/domain/usecases/orders_usecase.dart';
import 'package:talbatiyk/features/orders/presentation/controllers/orders_controller.dart';

void main() {
  late OrdersController controller;

  setUp(() {
    controller = OrdersController(
      OrdersUseCase(OrdersRepositoryImpl(OrdersLocalDataSource())),
      autoLoad: false,
    );
  });

  tearDown(() => controller.dispose());

  test('creates an order and adds it to state', () async {
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

    final created = await controller.createOrder(request);

    expect(created, isNotNull);
    expect(controller.state.isSubmitting, isFalse);
    expect(controller.state.orders.single.id, created!.id);
    expect(controller.state.lastCreatedOrder?.id, created.id);
  });

  test('loads orders created through the same data source', () async {
    final request = CreateOrderRequest(
      items: const [
        OrderItemEntity(
          productId: 'product-1',
          productName: 'شاحن سريع',
          unitPrice: 4500,
          quantity: 1,
        ),
      ],
    );

    await controller.createOrder(request);
    await controller.loadOrders();

    expect(controller.state.orders, hasLength(1));
    expect(controller.state.errorMessage, isNull);
  });
}

import '../../models/orders_model.dart';
import '../orders_datasource.dart';

class OrdersLocalDataSource implements OrdersDataSource {
  OrdersLocalDataSource({List<OrderModel> seedOrders = const []})
    : _orders = List<OrderModel>.of(seedOrders);

  final List<OrderModel> _orders;
  int _nextId = 1;

  @override
  Future<List<OrderModel>> getOrders() async {
    return List<OrderModel>.unmodifiable(_orders);
  }

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    final order = OrderModel(
      id: 'local-order-${_nextId++}',
      status: 'pending',
      items: request.items,
      createdAt: DateTime.now().toUtc(),
      notes: request.notes,
    );

    _orders.insert(0, order);
    return order;
  }
}

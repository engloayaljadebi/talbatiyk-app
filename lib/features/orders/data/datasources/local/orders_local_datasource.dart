import '../../models/orders_model.dart';
import '../orders_datasource.dart';

class OrdersLocalDataSource implements OrdersDataSource {
  OrdersLocalDataSource({List<OrderModel> seedOrders = const []})
    : _orders = List<OrderModel>.of(seedOrders);
  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final int orderIndex = _orders.indexWhere(
      (OrderModel order) => order.id == orderId,
    );

    if (orderIndex == -1) {
      throw StateError('Order not found: $orderId');
    }

    final OrderModel updatedOrder = _orders[orderIndex].copyWith(
      status: status,
    );

    _orders[orderIndex] = updatedOrder;

    return updatedOrder;
  }

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

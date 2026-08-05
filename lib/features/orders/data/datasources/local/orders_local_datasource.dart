import '../../models/orders_model.dart';
import '../orders_datasource.dart';

/// مصدر محلي مؤقت لحفظ الطلبيات داخل ذاكرة التطبيق.
///
/// سيظل محتوى القائمة موجودًا أثناء جلسة تشغيل التطبيق،
/// وسيُستبدل لاحقًا بقاعدة بيانات محلية دائمة.
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
    final OrderModel order = OrderModel(
      id: 'local-order-${_nextId++}',
      status: 'pending',
      items: request.items,
      createdAt: DateTime.now().toUtc(),
      supplier: request.supplier,
      notes: request.notes,
    );

    _orders.insert(0, order);

    return order;
  }

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
}

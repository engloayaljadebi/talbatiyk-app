import '../models/orders_model.dart';

abstract interface class OrdersDataSource {
  /// جلب جميع الطلبيات.
  Future<List<OrderModel>> getOrders();

  /// إنشاء طلبية جديدة.
  Future<OrderModel> createOrder(CreateOrderModel request);

  /// تحديث حالة طلبية موجودة.
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  });
}

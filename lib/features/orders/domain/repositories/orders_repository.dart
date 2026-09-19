import '../entities/orders_entity.dart';

abstract class OrdersRepository {
  /// جلب جميع الطلبيات.
  Future<List<OrderEntity>> getOrders();

  /// إنشاء طلبية جديدة.
  Future<OrderEntity> createOrder(CreateOrderRequest request);

  /// تحديث حالة طلبية.
}

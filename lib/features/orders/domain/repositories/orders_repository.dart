import '../entities/orders_entity.dart';

abstract class OrdersRepository {
  Future<List<OrderEntity>> getOrders();

  Future<OrderEntity> createOrder(CreateOrderRequest request);
}

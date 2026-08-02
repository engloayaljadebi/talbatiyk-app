import '../entities/orders_entity.dart';

abstract class OrdersRepository {
  Future<List<OrdersEntity>> getOrders();
}

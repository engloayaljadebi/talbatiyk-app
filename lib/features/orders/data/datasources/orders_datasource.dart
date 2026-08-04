import '../models/orders_model.dart';

abstract interface class OrdersDataSource {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> createOrder(CreateOrderModel request);
}

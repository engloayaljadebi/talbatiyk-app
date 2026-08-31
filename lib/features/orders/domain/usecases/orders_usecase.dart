import '../entities/orders_entity.dart';
import '../repositories/orders_repository.dart';

class OrdersUseCase {
  OrdersUseCase(this.repository);

  final OrdersRepository repository;

  Future<List<OrderEntity>> getOrders() {
    return repository.getOrders();
  }

  Future<OrderEntity> createOrder(CreateOrderRequest request) {
    return repository.createOrder(request);
  }
}

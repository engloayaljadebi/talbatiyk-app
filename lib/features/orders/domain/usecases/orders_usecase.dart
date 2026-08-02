import '../entities/orders_entity.dart';
import '../repositories/orders_repository.dart';

class OrdersUseCase {
  final OrdersRepository repository;

  OrdersUseCase(this.repository);

  Future<List<OrdersEntity>> call() {
    return repository.getOrders();
  }
}

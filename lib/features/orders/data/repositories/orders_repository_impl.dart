import '../../domain/entities/orders_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  @override
  Future<List<OrdersEntity>> getOrders() async {
    return [];
  }
}

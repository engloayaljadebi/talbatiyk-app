import '../../domain/entities/orders_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_datasource.dart';
import '../mappers/orders_mapper.dart';
import '../models/orders_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this.dataSource);
  @override
  Future<OrderEntity> updateOrderStatus({
    required String orderId,
    required OrderStatus status,
  }) async {
    final OrderModel updatedOrder = await dataSource.updateOrderStatus(
      orderId: orderId,
      status: OrdersMapper.statusToDataValue(status),
    );

    return OrdersMapper.toEntity(updatedOrder);
  }

  final OrdersDataSource dataSource;

  @override
  Future<List<OrderEntity>> getOrders() async {
    final models = await dataSource.getOrders();

    return List<OrderEntity>.unmodifiable(models.map(OrdersMapper.toEntity));
  }

  @override
  Future<OrderEntity> createOrder(CreateOrderRequest request) async {
    final createModel = OrdersMapper.toCreateModel(request);
    final order = await dataSource.createOrder(createModel);

    return OrdersMapper.toEntity(order);
  }
}

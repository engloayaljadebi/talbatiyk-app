import '../../domain/entities/orders_entity.dart';
import '../models/orders_model.dart';

class OrdersMapper {
  static OrdersEntity toEntity(OrdersModel model) {
    return OrdersEntity(id: model.id);
  }
}

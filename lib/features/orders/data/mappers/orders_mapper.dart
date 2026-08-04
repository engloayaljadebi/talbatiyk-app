import '../../domain/entities/orders_entity.dart';
import '../dto/orders_dto.dart';
import '../models/orders_model.dart';

class OrdersMapper {
  static OrderModel toModel(OrderDto dto) {
    return OrderModel(
      id: dto.id,
      status: dto.status,
      items: dto.items.map(_dtoItemToModel).toList(growable: false),
      createdAt: dto.createdAt,
      notes: dto.notes,
    );
  }

  static OrderEntity toEntity(OrderModel model) {
    return OrderEntity(
      id: model.id,
      status: _statusToEntity(model.status),
      items: model.items.map(_modelItemToEntity).toList(growable: false),
      createdAt: model.createdAt,
      notes: model.notes,
    );
  }

  static CreateOrderModel toCreateModel(CreateOrderRequest request) {
    return CreateOrderModel(
      items: request.items.map(_entityItemToModel).toList(growable: false),
      notes: request.notes,
    );
  }

  static OrderItemModel _dtoItemToModel(OrderItemDto dto) {
    return OrderItemModel(
      productId: dto.productId,
      productName: dto.productName,
      unitPrice: dto.unitPrice,
      quantity: dto.quantity,
      imageUrl: dto.imageUrl,
    );
  }

  static OrderItemEntity _modelItemToEntity(OrderItemModel model) {
    return OrderItemEntity(
      productId: model.productId,
      productName: model.productName,
      unitPrice: model.unitPrice,
      quantity: model.quantity,
      imageUrl: model.imageUrl,
    );
  }

  static OrderItemModel _entityItemToModel(OrderItemEntity entity) {
    return OrderItemModel(
      productId: entity.productId,
      productName: entity.productName,
      unitPrice: entity.unitPrice,
      quantity: entity.quantity,
      imageUrl: entity.imageUrl,
    );
  }

  static OrderStatus _statusToEntity(String value) {
    switch (value.trim().toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready_for_delivery':
      case 'readyfordelivery':
        return OrderStatus.readyForDelivery;
      case 'out_for_delivery':
      case 'outfordelivery':
        return OrderStatus.outForDelivery;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
      case 'canceled':
        return OrderStatus.cancelled;
      default:
        throw FormatException('Unsupported order status: $value');
    }
  }
}

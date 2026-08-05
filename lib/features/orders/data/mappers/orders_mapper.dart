import '../../domain/entities/orders_entity.dart';
import '../dto/orders_dto.dart';
import '../models/orders_model.dart';

/// يحوّل بيانات الطلبات بين DTO وModel وEntity.
class OrdersMapper {
  /// تحويل استجابة الـ API إلى نموذج بيانات.
  static OrderModel toModel(OrderDto dto) {
    return OrderModel(
      id: dto.id,
      status: dto.status,
      items: dto.items.map(_dtoItemToModel).toList(growable: false),
      createdAt: dto.createdAt,
      supplier: dto.supplier == null
          ? null
          : _dtoSupplierToModel(dto.supplier!),
      notes: dto.notes,
    );
  }

  /// تحويل حالة الطلب إلى القيمة المستخدمة في التخزين والـ API.
  static String statusToDataValue(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'pending';
      case OrderStatus.confirmed:
        return 'confirmed';
      case OrderStatus.preparing:
        return 'preparing';
      case OrderStatus.readyForDelivery:
        return 'ready_for_delivery';
      case OrderStatus.outForDelivery:
        return 'out_for_delivery';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }

  /// تحويل نموذج البيانات إلى كيان تستخدمه الواجهة.
  static OrderEntity toEntity(OrderModel model) {
    return OrderEntity(
      id: model.id,
      status: _statusToEntity(model.status),
      items: model.items.map(_modelItemToEntity).toList(growable: false),
      createdAt: model.createdAt,
      supplier: model.supplier == null
          ? null
          : _modelSupplierToEntity(model.supplier!),
      notes: model.notes,
    );
  }

  /// تحويل طلب الإنشاء من Domain إلى نموذج مصدر البيانات.
  static CreateOrderModel toCreateModel(CreateOrderRequest request) {
    return CreateOrderModel(
      items: request.items.map(_entityItemToModel).toList(growable: false),
      supplier: request.supplier == null
          ? null
          : _entitySupplierToModel(request.supplier!),
      notes: request.notes,
    );
  }

  static OrderSupplierModel _dtoSupplierToModel(OrderSupplierDto dto) {
    return OrderSupplierModel(id: dto.id, name: dto.name);
  }

  static OrderSupplierEntity _modelSupplierToEntity(OrderSupplierModel model) {
    return OrderSupplierEntity(id: model.id, name: model.name);
  }

  static OrderSupplierModel _entitySupplierToModel(OrderSupplierEntity entity) {
    return OrderSupplierModel(id: entity.id, name: entity.name);
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

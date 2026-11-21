import 'package:built_collection/built_collection.dart';
import 'package:talbytk_api/talbytk_api.dart';

import '../../../../../core/network/generated_api_client.dart';
import '../../models/orders_model.dart';
import '../orders_datasource.dart';

class OrdersRemoteDataSource implements OrdersDataSource {
  const OrdersRemoteDataSource({required this.generatedApiClient});

  final GeneratedApiClient generatedApiClient;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await generatedApiClient.orders.orderIndex(
      extra: generatedApiClient.captureOrderAuthExtra(),
    );
    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Orders response does not contain data.');
    }

    return List<OrderModel>.unmodifiable(
      responseBody.data.map(_mapOrderResource),
    );
  }

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    final String idempotencyKey = request.idempotencyKey.trim();

    if (idempotencyKey.isEmpty) {
      throw ArgumentError.value(
        request.idempotencyKey,
        'idempotencyKey',
        'Create order requires an idempotency key.',
      );
    }

    final apiRequest = CreateOrderRequest((builder) {
      final notes = request.notes.trim();

      if (notes.isNotEmpty) {
        builder.notes = notes;
      }

      builder.supplierIds.replace(BuiltList<String>(request.supplierIds));

      builder.items.replace(
        BuiltList<CreateOrderRequestItemsInner>(
          request.items.map(
            (item) => CreateOrderRequestItemsInner((itemBuilder) {
              itemBuilder.quantity = item.quantity;

              if (item.isManual) {
                itemBuilder
                  ..itemType = CreateOrderRequestItemsInnerItemTypeEnum.manual
                  ..name = item.productName
                  ..unitPrice = item.unitPrice
                  ..unit = item.unit
                  ..note = item.note;
                return;
              }

              final productId = item.productId;
              final supplierId = item.supplierId;

              if (item.itemType != 'catalog' ||
                  productId == null ||
                  productId.trim().isEmpty ||
                  supplierId == null ||
                  supplierId.trim().isEmpty) {
                throw const FormatException(
                  'A catalog order item requires a product and supplier.',
                );
              }

              // Preserve the catalog request shape for idempotent retries.
              itemBuilder
                ..productId = productId
                ..expectedUnitPrice = item.unitPrice
                ..expectedSupplierId = supplierId;
            }),
          ),
        ),
      );
    });

    final response = await generatedApiClient.orders.orderStore(
      idempotencyKey: idempotencyKey,
      createOrderRequest: apiRequest,
      extra: generatedApiClient.captureOrderAuthExtra(),
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Create order response does not contain data.');
    }

    return _mapOrderResource(responseBody.data);
  }

  OrderModel _mapOrderResource(OrderResource resource) {
    final createdAt = resource.createdAt;

    if (createdAt == null) {
      throw const FormatException(
        'Order response does not contain created_at.',
      );
    }

    return OrderModel(
      id: resource.id,
      status: resource.status,
      aggregateStatus: _aggregateStatusToDataValue(resource.aggregateStatus),
      notes: resource.notes ?? '',
      createdAt: createdAt,
      items: resource.items
          .map(
            (item) => OrderItemModel(
              productId: item.productId,
              productName: item.productName,
              unitPrice: double.parse(item.unitPrice),
              quantity: item.quantity,
              supplierId: item.supplierId,
              supplierName: item.supplierName ?? '',
              imageUrl: item.imageUrl ?? '',
              itemType: item.itemType,
              unit: item.unit,
              note: item.note,
            ),
          )
          .toList(growable: false),
    );
  }

  String _aggregateStatusToDataValue(OrderAggregateStatus status) {
    if (status == OrderAggregateStatus.pendingResponses) {
      return 'pending_responses';
    }

    if (status == OrderAggregateStatus.responsesReceived) {
      return 'responses_received';
    }

    if (status == OrderAggregateStatus.suppliersSelected) {
      return 'suppliers_selected';
    }

    if (status == OrderAggregateStatus.inFulfillment) {
      return 'in_fulfillment';
    }

    if (status == OrderAggregateStatus.partiallyCompleted) {
      return 'partially_completed';
    }

    if (status == OrderAggregateStatus.completed) {
      return 'completed';
    }

    if (status == OrderAggregateStatus.cancelled) {
      return 'cancelled';
    }

    if (status == OrderAggregateStatus.expired) {
      return 'expired';
    }

    throw FormatException(
      'Unsupported generated aggregate order status: $status',
    );
  }
}

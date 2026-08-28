import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../../../../core/network/api_client.dart';
import '../../../../../core/network/generated_api_client.dart';
import '../../dto/orders_dto.dart';
import '../../mappers/orders_mapper.dart';
import '../../models/orders_model.dart';
import '../orders_datasource.dart';

class OrdersRemoteDataSource implements OrdersDataSource {
  const OrdersRemoteDataSource({
    required this.generatedApiClient,
    this.client,
    this.endpoint = '/orders',
  });

  final GeneratedApiClient generatedApiClient;

  /// Legacy client used only by getOrders until GET /orders
  /// is available in the generated OpenAPI client.
  final ApiClient? client;

  final String endpoint;

  @override
  Future<List<OrderModel>> getOrders() async {
    final ApiClient? legacyClient = client;

    if (legacyClient == null) {
      throw UnsupportedError(
        'GET /orders is not available in the generated API client yet.',
      );
    }

    final response = await legacyClient.get(endpoint);
    final items = _extractList(response);

    return List<OrderModel>.unmodifiable(
      items.map((item) {
        final dto = OrderDto.fromJson(_asJsonMap(item));

        return OrdersMapper.toModel(dto);
      }),
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

      builder.items.replace(
        BuiltList<CreateOrderRequestItemsInner>(
          request.items.map(
            (item) => CreateOrderRequestItemsInner((itemBuilder) {
              /*
               * Flutter sends the commercial values it observed.
               * Laravel resolves the authoritative Product snapshot and
               * rejects stale price/supplier expectations explicitly.
               */
              itemBuilder
                ..productId = item.productId
                ..quantity = item.quantity
                ..expectedUnitPrice = item.unitPrice
                ..expectedSupplierId = item.supplierId;
            }),
          ),
        ),
      );
    });

    final response = await generatedApiClient.orders.orderStore(
      idempotencyKey: idempotencyKey,
      createOrderRequest: apiRequest,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Create order response does not contain data.');
    }

    return _mapOrderResource(responseBody.data);
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    throw UnsupportedError(
      'Order status API endpoint has not been configured yet.',
    );
  }

  OrderModel _mapOrderResource(OrderResource resource) {
    final createdAt = resource.createdAt;

    if (createdAt == null) {
      throw const FormatException(
        'Created order response does not contain created_at.',
      );
    }

    return OrderModel(
      id: resource.id,
      status: resource.status,
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
              supplierName: item.supplierName,
              imageUrl: item.imageUrl ?? '',
            ),
          )
          .toList(growable: false),
    );
  }

  List<Object?> _extractList(Object? payload) {
    if (payload is List) {
      return payload.cast<Object?>();
    }

    if (payload is Map) {
      for (final key in const ['data', 'items', 'orders']) {
        if (payload.containsKey(key)) {
          return _extractList(payload[key]);
        }
      }
    }

    throw const FormatException(
      'Orders response must contain a list of orders.',
    );
  }

  Map<String, dynamic> _asJsonMap(Object? value) {
    if (value is! Map) {
      throw const FormatException('Each order must be a JSON object.');
    }

    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}

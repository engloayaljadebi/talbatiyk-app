import '../../../../../core/network/api_client.dart';
import '../../dto/orders_dto.dart';
import '../../mappers/orders_mapper.dart';
import '../../models/orders_model.dart';
import '../orders_datasource.dart';

class OrdersRemoteDataSource implements OrdersDataSource {
  const OrdersRemoteDataSource({
    required this.client,
    this.endpoint = '/orders',
  });
  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    throw UnsupportedError(
      'Order status API endpoint has not been configured yet.',
    );
  }

  final ApiClient client;
  final String endpoint;

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await client.get(endpoint);
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
    final response = await client.post(endpoint, body: request.toJson());
    final payload = _extractOrder(response);
    final dto = OrderDto.fromJson(_asJsonMap(payload));

    return OrdersMapper.toModel(dto);
  }

  List<Object?> _extractList(Object? payload) {
    if (payload is List) return payload.cast<Object?>();

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

  Object? _extractOrder(Object? payload) {
    if (payload is Map) {
      if (payload.containsKey('id')) return payload;

      for (final key in const ['data', 'order']) {
        if (payload.containsKey(key)) {
          return _extractOrder(payload[key]);
        }
      }
    }

    throw const FormatException(
      'Create order response must contain an order object.',
    );
  }

  Map<String, dynamic> _asJsonMap(Object? value) {
    if (value is! Map) {
      throw const FormatException('Each order must be a JSON object.');
    }

    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}

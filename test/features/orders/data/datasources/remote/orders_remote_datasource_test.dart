import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/api_client.dart';
import 'package:talbatiyk/features/orders/data/datasources/remote/orders_remote_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  group('OrdersRemoteDataSource', () {
    test('loads orders from a nested response', () async {
      final client = _FakeApiClient(getResponse: _orderEnvelope());
      final dataSource = OrdersRemoteDataSource(client: client);

      final orders = await dataSource.getOrders();

      expect(client.getPath, '/orders');
      expect(orders.single.id, 'order-1');
      expect(orders.single.items.single.productId, 'product-1');
    });

    test('posts the request and parses the created order', () async {
      final client = _FakeApiClient(postResponse: {'data': _orderJson()});
      final dataSource = OrdersRemoteDataSource(client: client);
      final request = CreateOrderModel(
        items: const [
          OrderItemModel(
            productId: 'product-1',
            productName: 'شاحن سريع',
            unitPrice: 4500,
            quantity: 2,
          ),
        ],
        notes: 'التواصل قبل التسليم',
      );

      final created = await dataSource.createOrder(request);

      expect(client.postPath, '/orders');
      expect(created.id, 'order-1');
      expect(client.postBody, {
        'items': [
          {
            'product_id': 'product-1',
            'product_name': 'شاحن سريع',
            'unit_price': 4500.0,
            'quantity': 2,
            'image_url': '',
          },
        ],
        'notes': 'التواصل قبل التسليم',
      });
    });
  });
}

Map<String, dynamic> _orderEnvelope() {
  return {
    'data': {
      'orders': [_orderJson()],
    },
  };
}

Map<String, dynamic> _orderJson() {
  return {
    'id': 'order-1',
    'status': 'pending',
    'created_at': '2026-08-04T00:00:00Z',
    'items': [
      {
        'product_id': 'product-1',
        'product_name': 'شاحن سريع',
        'unit_price': 4500,
        'quantity': 2,
        'image_url': '',
      },
    ],
  };
}

class _FakeApiClient implements ApiClient {
  _FakeApiClient({this.getResponse, this.postResponse});

  final Object? getResponse;
  final Object? postResponse;

  String? getPath;
  String? postPath;
  Object? postBody;

  @override
  Future<Object?> get(
    String path, {
    Map<String, Object?>? queryParameters,
  }) async {
    getPath = path;
    return getResponse;
  }

  @override
  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
  }) async {
    postPath = path;
    postBody = body;
    return postResponse;
  }
}

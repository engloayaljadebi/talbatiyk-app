import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/api_client.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/orders/data/datasources/remote/orders_remote_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  group('OrdersRemoteDataSource', () {
    test('loads orders from a nested response', () async {
      final client = _FakeApiClient(getResponse: _orderEnvelope());

      final generatedApiClient = GeneratedApiClient.create(
        baseUrl: 'http://localhost/api/v1',
      );

      final dataSource = OrdersRemoteDataSource(
        client: client,
        generatedApiClient: generatedApiClient,
      );

      final orders = await dataSource.getOrders();

      expect(client.getPath, '/orders');
      expect(orders, hasLength(1));

      final order = orders.single;

      expect(order.id, 'order-1');
      expect(order.status, 'pending');
      expect(order.createdAt, DateTime.parse('2026-08-04T00:00:00Z'));

      expect(order.items, hasLength(1));
      expect(order.items.single.productId, 'product-1');
    });

    test(
      'posts the request through generated API and maps created order',
      () async {
        final adapter = _RecordingHttpClientAdapter(
          responseBody: {
            'data': {
              'id': 'order-1',
              'status': 'pending',
              'notes': 'Call before delivery',
              'items': [
                {
                  'id': 'item-1',
                  'product_id': 'product-1',
                  'product_name': 'Fast charger',
                  'unit_price': '4500.00',
                  'quantity': 2,
                  'supplier_id': 'supplier-1',
                  'supplier_name': 'Supplier 1',
                  'image_url': null,
                },
              ],
              'created_at': '2026-08-04T00:00:00Z',
              'updated_at': '2026-08-04T00:00:00Z',
            },
          },
        );

        final generatedApiClient = GeneratedApiClient.create(
          baseUrl: 'http://localhost/api/v1',
        );

        generatedApiClient.client.dio.httpClientAdapter = adapter;

        final client = _FakeApiClient();

        final dataSource = OrdersRemoteDataSource(
          client: client,
          generatedApiClient: generatedApiClient,
        );

        final request = CreateOrderModel(
          idempotencyKey: '550e8400-e29b-41d4-a716-446655440000',
          items: const [
            OrderItemModel(
              productId: 'product-1',
              productName: 'Fast charger',
              unitPrice: 4500,
              quantity: 2,
              supplierId: 'supplier-1',
              supplierName: 'Supplier 1',
            ),
          ],
          notes: 'Call before delivery',
        );

        final created = await dataSource.createOrder(request);

        final requestOptions = adapter.requestOptions;

        expect(requestOptions, isNotNull);
        expect(requestOptions!.method, 'POST');
        expect(requestOptions.path, '/orders');
        expect(
          requestOptions.headers['Idempotency-Key'],
          '550e8400-e29b-41d4-a716-446655440000',
        );

        expect(requestOptions.data, {
          'items': [
            {
              'product_id': 'product-1',
              'product_name': 'Fast charger',
              'unit_price': 4500.0,
              'quantity': 2,
              'supplier_id': 'supplier-1',
              'supplier_name': 'Supplier 1',
            },
          ],
          'notes': 'Call before delivery',
        });

        expect(created.id, 'order-1');
        expect(created.status, 'pending');
        expect(created.notes, 'Call before delivery');

        expect(created.createdAt, DateTime.parse('2026-08-04T00:00:00Z'));

        expect(created.items, hasLength(1));

        final item = created.items.single;

        expect(item.productId, 'product-1');
        expect(item.productName, 'Fast charger');
        expect(item.unitPrice, 4500.0);
        expect(item.quantity, 2);
        expect(item.supplierId, 'supplier-1');
        expect(item.supplierName, 'Supplier 1');

        // OrderItemModel uses an empty string when the API image is null.
        expect(item.imageUrl, '');

        // createOrder must use the generated OrderApi,
        // not the old ApiClient.post path.
        expect(client.postPath, isNull);
        expect(client.postBody, isNull);
      },
    );
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
        'product_name': 'Fast charger',
        'unit_price': 4500,
        'quantity': 2,
        'supplier_id': 'supplier-1',
        'supplier_name': 'Supplier 1',
        'image_url': '',
      },
    ],
  };
}

class _FakeApiClient implements ApiClient {
  _FakeApiClient({this.getResponse});

  final Object? getResponse;

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

    return null;
  }
}

class _RecordingHttpClientAdapter implements HttpClientAdapter {
  _RecordingHttpClientAdapter({required this.responseBody});

  final Map<String, dynamic> responseBody;

  RequestOptions? requestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestOptions = options;

    return ResponseBody.fromString(
      jsonEncode(responseBody),
      201,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

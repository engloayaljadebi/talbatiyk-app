import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/orders/data/datasources/remote/orders_remote_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  group('OrdersRemoteDataSource', () {
    test(
      'loads orders through generated API and maps aggregate status',
      () async {
        final adapter = _RecordingHttpClientAdapter(
          responseBody: _orderIndexEnvelope(),
        );

        final generatedApiClient = GeneratedApiClient.create(
          baseUrl: 'http://localhost/api/v1',
        );

        generatedApiClient.client.dio.httpClientAdapter = adapter;

        final dataSource = OrdersRemoteDataSource(
          generatedApiClient: generatedApiClient,
        );

        final orders = await dataSource.getOrders();

        final requestOptions = adapter.requestOptions;

        expect(requestOptions, isNotNull);
        expect(requestOptions!.method, 'GET');
        expect(requestOptions.path, '/orders');

        expect(orders, hasLength(1));

        final order = orders.single;

        expect(order.id, 'order-1');
        expect(order.status, 'pending');
        expect(order.aggregateStatus, 'responses_received');
        expect(order.createdAt, DateTime.parse('2026-08-04T00:00:00Z'));

        expect(order.items, hasLength(1));
        expect(order.items.single.productId, 'product-1');
        expect(order.items.single.supplierId, 'supplier-1');
        expect(order.items.single.imageUrl, '');
      },
    );

    test(
      'posts the request through generated API and maps created order',
      () async {
        final adapter = _RecordingHttpClientAdapter(
          responseBody: _orderStoreEnvelope(),
        );

        final generatedApiClient = GeneratedApiClient.create(
          baseUrl: 'http://localhost/api/v1',
        );

        generatedApiClient.client.dio.httpClientAdapter = adapter;

        final dataSource = OrdersRemoteDataSource(
          generatedApiClient: generatedApiClient,
        );

        final request = CreateOrderModel(
          supplierIds: const ['supplier-1'],
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
              'quantity': 2,
              'expected_unit_price': 4500.0,
              'expected_supplier_id': 'supplier-1',
            },
          ],
          'notes': 'Call before delivery',
          'supplier_ids': ['supplier-1'],
        });

        expect(created.id, 'order-1');
        expect(created.aggregateStatus, 'pending_responses');
        expect(created.items, hasLength(1));

        final item = created.items.single;

        expect(item.productId, 'product-1');
        expect(item.supplierName, 'Supplier 1');
        expect(item.imageUrl, '');
      },
    );
  });
}

Map<String, dynamic> _orderIndexEnvelope() {
  return {
    'data': [_orderJson(aggregateStatus: 'responses_received')],
  };
}

Map<String, dynamic> _orderStoreEnvelope() {
  return {'data': _orderJson(aggregateStatus: 'pending_responses')};
}

Map<String, dynamic> _orderJson({required String aggregateStatus}) {
  return {
    'id': 'order-1',
    'status': 'pending',
    'aggregate_status': aggregateStatus,
    'notes': 'Call before delivery',
    'created_at': '2026-08-04T00:00:00Z',
    'updated_at': '2026-08-04T00:00:00Z',
    'items': [
      {
        'id': 'order-item-1',
        'product_id': 'product-1',
        'product_name': 'Fast charger',
        'unit_price': '4500.00',
        'quantity': 2,
        'supplier_id': 'supplier-1',
        'supplier_name': 'Supplier 1',
        'image_url': null,
      },
    ],
  };
}

final class _RecordingHttpClientAdapter implements HttpClientAdapter {
  _RecordingHttpClientAdapter({required this.responseBody});

  final Object responseBody;

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
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

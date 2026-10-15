import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/products/data/datasources/remote/products_remote_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/remote/orders_remote_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';

void main() {
  group('Order HTTP account token isolation', () {
    test('queued GET must not use replacement account token', () async {
      await _checkDispatch(create: false, logout: false);
    });

    test('queued POST must not use replacement account token', () async {
      await _checkDispatch(create: true, logout: false);
    });

    test('A to B to A must reject queued GET', () async {
      await _checkDispatch(create: false, logout: false, reloginOriginal: true);
    });

    test('A to B to A must reject queued POST', () async {
      await _checkDispatch(create: true, logout: false, reloginOriginal: true);
    });

    test('queued product DELETE rejects account switch', () async {
      final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');

      api.setAccessToken('fake-account-A-token');

      final adapter = _RecordingAdapter();
      api.client.dio.httpClientAdapter = adapter;

      final entered = Completer<void>();
      final release = Completer<void>();

      api.client.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            entered.complete();
            release.future.then((_) => handler.next(options));
          },
        ),
      );

      final pending = ProductsRemoteDataSource(api).deleteProductMutation(
        businessId: 'business-A',
        productId: 'product-A',
        expectedVersion: 4,
      );

      await entered.future;

      api.setAccessToken('fake-account-B-token');
      release.complete();

      try {
        await pending;
      } catch (_) {
        // Rejecting stale authentication is acceptable.
      }

      expect(
        adapter.requestCount,
        0,
        reason: 'Product A DELETE must not use account B credentials.',
      );
    });

    test('logout must prevent queued GET from dispatching', () async {
      await _checkDispatch(create: false, logout: true);
    });
  });
}

Future<void> _checkDispatch({
  required bool create,
  required bool logout,
  bool reloginOriginal = false,
}) async {
  final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');

  api.setAccessToken('fake-account-A-token');

  final adapter = _RecordingAdapter();
  api.client.dio.httpClientAdapter = adapter;

  final reachedInterceptor = Completer<void>();
  final releaseRequest = Completer<void>();

  // Hold the request before the generated Bearer interceptor.
  api.client.dio.interceptors.insert(
    0,
    InterceptorsWrapper(
      onRequest: (options, handler) {
        reachedInterceptor.complete();
        releaseRequest.future.then((_) => handler.next(options));
      },
    ),
  );

  final remote = OrdersRemoteDataSource(generatedApiClient: api);

  final Future<Object?> pending;

  if (create) {
    pending = remote.createOrder(
      CreateOrderModel(
        supplierIds: const ['supplier-test'],
        idempotencyKey: '550e8400-e29b-41d4-a716-446655440000',
        items: const [
          OrderItemModel(
            productId: 'product-test',
            productName: 'Test product',
            unitPrice: 100,
            quantity: 1,
            supplierId: 'supplier-test',
            supplierName: 'Test supplier',
          ),
        ],
      ),
    );
  } else {
    pending = remote.getOrders();
  }

  await reachedInterceptor.future;

  if (logout) {
    api.clearAccessToken();
  } else {
    api.setAccessToken('fake-account-B-token');
    if (reloginOriginal) {
      api.setAccessToken('fake-account-A-token');
    }
  }

  releaseRequest.complete();

  try {
    await pending;
  } catch (_) {
    // Rejecting an invalidated request is an acceptable secure result.
  }

  if (logout || reloginOriginal) {
    expect(
      adapter.requestCount,
      0,
      reason:
          'An unsent request must be rejected after logout or token rotation.',
    );
  } else {
    expect(
      adapter.authorization,
      isNot('Bearer fake-account-B-token'),
      reason: 'A queued request for A must never use B credentials.',
    );
  }
}

final class _RecordingAdapter implements HttpClientAdapter {
  int requestCount = 0;
  String? authorization;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    authorization = options.headers['Authorization']?.toString();

    return ResponseBody.fromString(
      '{"data":[]}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

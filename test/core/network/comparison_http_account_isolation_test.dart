import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/order_response_comparison/data/datasources/remote/order_response_comparison_remote_datasource.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/entities/order_response_comparison_entity.dart';

const _orderId = '11111111-1111-4111-8111-111111111111';

void main() {
  for (final operation in ['show', 'replaceSelections']) {
    test('queued $operation rejects account switch', () async {
      final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');
      api.setAccessToken('fake-account-A-token');

      final adapter = _CountingAdapter();
      api.client.dio.httpClientAdapter = adapter;

      final entered = Completer<void>();
      final release = Completer<void>();

      api.client.dio.interceptors.insert(
        0,
        InterceptorsWrapper(
          onRequest: (options, handler) {
            if (!entered.isCompleted) entered.complete();
            release.future.then((_) => handler.next(options));
          },
        ),
      );

      final source = OrderResponseComparisonRemoteDataSourceImpl(api);
      final pending = _invoke(operation, source);

      await entered.future.timeout(const Duration(seconds: 5));

      api.setAccessToken('fake-account-B-token');
      release.complete();

      try {
        await pending;
      } catch (_) {
        // Rejecting the obsolete request is expected.
      }

      expect(
        adapter.requestCount,
        0,
        reason: 'Old account $operation reached the network.',
      );
    });

    test('$operation rejects stale HTTP response', () async {
      final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');
      api.setAccessToken('fake-account-A-token');

      final adapter = _CountingAdapter();
      adapter.onFetch = () {
        api.setAccessToken('fake-account-B-token');
      };

      api.client.dio.httpClientAdapter = adapter;

      final source = OrderResponseComparisonRemoteDataSourceImpl(api);

      await expectLater(_invoke(operation, source), throwsA(isA<StateError>()));

      expect(adapter.requestCount, 1);
    });
  }
}

Future<Object?> _invoke(
  String operation,
  OrderResponseComparisonRemoteDataSourceImpl source,
) {
  if (operation == 'show') {
    return source.show(orderId: _orderId);
  }

  return source.replaceSelections(
    orderId: _orderId,
    expectedVersion: 1,
    selections: const [
      OrderResponseSelectionInput(
        orderRecipientItemResponseId: '66666666-6666-4666-8666-666666666666',
        selectedQuantity: 1,
      ),
    ],
  );
}

final class _CountingAdapter implements HttpClientAdapter {
  int requestCount = 0;
  void Function()? onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requestCount++;
    onFetch?.call();

    return ResponseBody.fromString(
      r'''
{
  "data": {
    "id": "11111111-1111-4111-8111-111111111111",
    "version": 1,
    "status": "pending",
    "aggregate_status": "responses_received",
    "notes": null,
    "items": [
      {
        "id": "22222222-2222-4222-8222-222222222222",
        "product_id": "product-1",
        "product_name": "Product One",
        "requested_quantity": 3,
        "order_unit_price": "12.50",
        "supplier": {
          "recipient_id": "33333333-3333-4333-8333-333333333333",
          "supplier_id": "44444444-4444-4444-8444-444444444444",
          "supplier_name": "Supplier One"
        },
        "response": {
          "id": "66666666-6666-4666-8666-666666666666",
          "order_recipient_item_id": "55555555-5555-4555-8555-555555555555",
          "requested_quantity": 3,
          "available_quantity": 2,
          "availability_status": "partial",
          "offered_unit_price": "11.25",
          "response_notes": "Two units available now",
          "created_at": "2026-08-30T01:10:00+03:00",
          "updated_at": "2026-08-30T01:10:00+03:00"
        },
        "selection": null
      }
    ],
    "created_at": "2026-08-30T01:00:00+03:00",
    "updated_at": "2026-08-30T01:10:00+03:00"
  }
}
''',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/received_orders/data/datasources/remote/received_orders_remote_datasource.dart';
import 'package:talbatiyk/features/received_orders/domain/entities/received_order_entity.dart';

const businessId = '11111111-1111-4111-8111-111111111111';
const recipientId = '22222222-2222-4222-8222-222222222222';
const itemId = '44444444-4444-4444-8444-444444444444';

void main() {
  for (final operation in ['index', 'submitResponse', 'updateFulfillment']) {
    test('queued $operation rejects account switch', () async {
      final api = GeneratedApiClient.create(baseUrl: 'http://localhost/api/v1');
      api.setAccessToken('fake-account-A-token');

      final adapter = _CountingAdapter(_responseBody(operation));
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

      final source = ReceivedOrdersRemoteDataSourceImpl(api);
      final pending = _invoke(operation, source);

      await entered.future.timeout(const Duration(seconds: 5));

      api.setAccessToken('fake-account-B-token');
      release.complete();

      try {
        await pending;
      } catch (_) {
        // A stale request may be rejected.
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

      final adapter = _CountingAdapter(_responseBody(operation));
      adapter.onFetch = () {
        api.setAccessToken('fake-account-B-token');
      };

      api.client.dio.httpClientAdapter = adapter;

      final source = ReceivedOrdersRemoteDataSourceImpl(api);

      await expectLater(_invoke(operation, source), throwsA(isA<StateError>()));

      expect(adapter.requestCount, 1);
    });
  }
}

Future<Object?> _invoke(
  String operation,
  ReceivedOrdersRemoteDataSourceImpl source,
) {
  switch (operation) {
    case 'index':
      return source.index(businessId: businessId);

    case 'submitResponse':
      return source.submitResponse(
        businessId: businessId,
        recipientId: recipientId,
        idempotencyKey: '550e8400-e29b-41d4-a716-446655440000',
        items: const [
          SubmitReceivedOrderItemResponse(
            orderRecipientItemId: itemId,
            availability: ReceivedOrderAvailability.partial,
            availableQuantity: 2,
            offeredUnitPrice: 11.25,
          ),
        ],
      );

    case 'updateFulfillment':
      return source.updateFulfillment(
        businessId: businessId,
        recipientId: recipientId,
        expectedVersion: 2,
        status: ReceivedOrderFulfillmentStatus.preparing,
      );

    default:
      throw ArgumentError.value(operation);
  }
}

String _responseBody(String operation) {
  switch (operation) {
    case 'index':
      return '{"data":[]}';

    case 'submitResponse':
      return '''
{
  "data": {
    "id": "66666666-6666-4666-8666-666666666666",
    "order_recipient_id": "$recipientId",
    "items": [],
    "created_at": "2026-08-30T01:10:00+03:00",
    "updated_at": "2026-08-30T01:10:00+03:00"
  }
}
''';

    case 'updateFulfillment':
      return '''
{
  "data": {
    "id": "$recipientId",
    "order_id": "33333333-3333-4333-8333-333333333333",
    "supplier_id": "$businessId",
    "supplier_name": "Supplier One",
    "fulfillment_status": "preparing",
    "fulfillment_version": 3,
    "order_status": "pending",
    "notes": "Test only",
    "items": [],
    "created_at": "2026-08-30T01:00:00+03:00",
    "updated_at": "2026-08-30T01:15:00+03:00"
  }
}
''';

    default:
      throw ArgumentError.value(operation);
  }
}

final class _CountingAdapter implements HttpClientAdapter {
  _CountingAdapter(this.responseJson);

  final String responseJson;
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
      responseJson,
      options.method == 'POST' ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

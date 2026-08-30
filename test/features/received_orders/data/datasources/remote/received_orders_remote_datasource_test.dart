import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/received_orders/data/datasources/remote/received_orders_remote_datasource.dart';
import 'package:talbatiyk/features/received_orders/domain/entities/received_order_entity.dart';
import 'package:talbatiyk/features/received_orders/domain/errors/stale_recipient_fulfillment_version_exception.dart';

void main() {
  group('ReceivedOrdersRemoteDataSourceImpl', () {
    late HttpServer server;
    late GeneratedApiClient apiClient;
    late ReceivedOrdersRemoteDataSourceImpl dataSource;

    const accessToken = 'received-orders-test-token';

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
      apiClient.setAccessToken(accessToken);

      dataSource = ReceivedOrdersRemoteDataSourceImpl(apiClient);
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test('index sends supplier-scoped GET and maps received orders', () async {
      const businessId = '11111111-1111-4111-8111-111111111111';

      const recipientId = '22222222-2222-4222-8222-222222222222';

      const orderId = '33333333-3333-4333-8333-333333333333';

      const itemId = '44444444-4444-4444-8444-444444444444';

      final requestFuture = server.first;

      final resultFuture = dataSource.index(businessId: '  $businessId  ');

      final request = await requestFuture;

      expect(request.method, 'GET');

      expect(
        request.uri.path,
        '/api/v1/businesses/$businessId/received-orders',
      );

      expect(
        request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer $accessToken',
      );

      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;

      request.response.write(
        jsonEncode({
          'data': [
            {
              'id': recipientId,
              'order_id': orderId,
              'supplier_id': businessId,
              'supplier_name': 'Supplier One',
              'fulfillment_status': null,
              'fulfillment_version': 1,
              'order_status': 'pending',
              'notes': 'Deliver this week',
              'items': [
                {
                  'id': itemId,
                  'product_id': '55555555-5555-4555-8555-555555555555',
                  'product_name': 'Product One',
                  'unit_price': '12.50',
                  'requested_quantity': 3,
                  'selected_quantity': null,
                },
              ],
              'created_at': '2026-08-30T01:00:00+03:00',
              'updated_at': '2026-08-30T01:05:00+03:00',
            },
          ],
        }),
      );

      await request.response.close();

      final result = await resultFuture;

      expect(result, hasLength(1));

      final recipient = result.single;

      expect(recipient.id, recipientId);
      expect(recipient.orderId, orderId);
      expect(recipient.supplierId, businessId);
      expect(recipient.fulfillmentStatus, isNull);
      expect(recipient.fulfillmentVersion, 1);
      expect(recipient.items, hasLength(1));
      expect(recipient.items.single.requestedQuantity, 3);
      expect(recipient.items.single.selectedQuantity, isNull);
    });

    test(
      'submitResponse sends POST with idempotency key and items only',
      () async {
        const businessId = '11111111-1111-4111-8111-111111111111';

        const recipientId = '22222222-2222-4222-8222-222222222222';

        const recipientItemId = '44444444-4444-4444-8444-444444444444';

        const responseId = '66666666-6666-4666-8666-666666666666';

        const responseItemId = '77777777-7777-4777-8777-777777777777';

        const idempotencyKey = '550e8400-e29b-41d4-a716-446655440000';

        final requestFuture = server.first;

        final resultFuture = dataSource.submitResponse(
          businessId: businessId,
          recipientId: recipientId,
          idempotencyKey: idempotencyKey,
          items: const [
            SubmitReceivedOrderItemResponse(
              orderRecipientItemId: recipientItemId,
              availability: ReceivedOrderAvailability.partial,
              availableQuantity: 2,
              offeredUnitPrice: 11.25,
              responseNotes: 'Two units available now',
            ),
          ],
        );

        final request = await requestFuture;

        expect(request.method, 'POST');

        expect(
          request.uri.path,
          '/api/v1/businesses/$businessId/'
          'received-orders/$recipientId/response',
        );

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $accessToken',
        );

        expect(request.headers.value('Idempotency-Key'), idempotencyKey);

        final rawBody = await utf8.decoder.bind(request).join();

        final body = jsonDecode(rawBody) as Map<String, dynamic>;

        expect(body.keys, <String>{'items'});

        final items = body['items'] as List<dynamic>;

        expect(items, hasLength(1));

        final item = items.single as Map<String, dynamic>;

        expect(item['order_recipient_item_id'], recipientItemId);

        expect(item['availability_status'], 'partial');

        expect(item['available_quantity'], 2);
        expect(item['offered_unit_price'], 11.25);

        expect(item['response_notes'], 'Two units available now');

        expect(item.containsKey('requested_quantity'), isFalse);

        request.response.statusCode = HttpStatus.created;
        request.response.headers.contentType = ContentType.json;

        request.response.write(
          jsonEncode({
            'data': {
              'id': responseId,
              'order_recipient_id': recipientId,
              'items': [
                {
                  'id': responseItemId,
                  'order_recipient_item_id': recipientItemId,
                  'requested_quantity': 3,
                  'available_quantity': 2,
                  'availability_status': 'partial',
                  'offered_unit_price': '11.25',
                  'response_notes': 'Two units available now',
                  'created_at': '2026-08-30T01:10:00+03:00',
                  'updated_at': '2026-08-30T01:10:00+03:00',
                },
              ],
              'created_at': '2026-08-30T01:10:00+03:00',
              'updated_at': '2026-08-30T01:10:00+03:00',
            },
          }),
        );

        await request.response.close();

        final result = await resultFuture;

        expect(result.id, responseId);
        expect(result.orderRecipientId, recipientId);
        expect(result.items, hasLength(1));

        expect(result.items.single.availableQuantity, 2);
      },
    );

    test(
      'updateFulfillment sends supplier-scoped PATCH and maps updated recipient',
      () async {
        const businessId = '11111111-1111-4111-8111-111111111111';
        const recipientId = '22222222-2222-4222-8222-222222222222';
        const orderId = '33333333-3333-4333-8333-333333333333';
        const itemId = '44444444-4444-4444-8444-444444444444';

        final requestFuture = server.first;

        final resultFuture = dataSource.updateFulfillment(
          businessId: '  $businessId  ',
          recipientId: '  $recipientId  ',
          expectedVersion: 2,
          status: ReceivedOrderFulfillmentStatus.preparing,
        );

        final request = await requestFuture;

        expect(request.method, 'PATCH');

        expect(
          request.uri.path,
          '/api/v1/businesses/$businessId/'
          'received-orders/$recipientId/fulfillment',
        );

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $accessToken',
        );

        final rawBody = await utf8.decoder.bind(request).join();
        final body = jsonDecode(rawBody) as Map<String, dynamic>;

        expect(body.keys, <String>{'expected_version', 'status'});
        expect(body['expected_version'], 2);
        expect(body['status'], 'preparing');

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;

        request.response.write(
          jsonEncode({
            'data': {
              'id': recipientId,
              'order_id': orderId,
              'supplier_id': businessId,
              'supplier_name': 'Supplier One',
              'fulfillment_status': 'preparing',
              'fulfillment_version': 3,
              'order_status': 'pending',
              'notes': 'Deliver this week',
              'items': [
                {
                  'id': itemId,
                  'product_id': '55555555-5555-4555-8555-555555555555',
                  'product_name': 'Product One',
                  'unit_price': '12.50',
                  'requested_quantity': 3,
                  'selected_quantity': 2,
                },
              ],
              'created_at': '2026-08-30T01:00:00+03:00',
              'updated_at': '2026-08-30T01:15:00+03:00',
            },
          }),
        );

        await request.response.close();

        final result = await resultFuture;

        expect(result.id, recipientId);
        expect(result.fulfillmentStatus?.name, 'preparing');
        expect(result.fulfillmentVersion, 3);
        expect(result.items, hasLength(1));
        expect(result.items.single.selectedQuantity, 2);
      },
    );

    test(
      'updateFulfillment maps HTTP 409 to stale fulfillment version exception',
      () async {
        const businessId = '11111111-1111-4111-8111-111111111111';
        const recipientId = '22222222-2222-4222-8222-222222222222';

        final requestFuture = server.first;

        final expectation = expectLater(
          dataSource.updateFulfillment(
            businessId: businessId,
            recipientId: recipientId,
            expectedVersion: 2,
            status: ReceivedOrderFulfillmentStatus.preparing,
          ),
          throwsA(isA<StaleRecipientFulfillmentVersionException>()),
        );

        final request = await requestFuture;

        expect(request.method, 'PATCH');

        request.response.statusCode = HttpStatus.conflict;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({'message': 'The fulfillment state has changed.'}),
        );

        await request.response.close();

        await expectation;
      },
    );

    test('updateFulfillment rejects confirmed derived state', () async {
      await expectLater(
        dataSource.updateFulfillment(
          businessId: '11111111-1111-4111-8111-111111111111',
          recipientId: '22222222-2222-4222-8222-222222222222',
          expectedVersion: 1,
          status: ReceivedOrderFulfillmentStatus.confirmed,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });
    test('index rejects empty business id before network call', () async {
      await expectLater(
        dataSource.index(businessId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}

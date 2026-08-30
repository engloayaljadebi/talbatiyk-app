import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/order_response_comparison/data/datasources/remote/order_response_comparison_remote_datasource.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/entities/order_response_comparison_entity.dart';
import 'package:talbatiyk/features/order_response_comparison/domain/errors/stale_order_version_exception.dart';

void main() {
  group('OrderResponseComparisonRemoteDataSourceImpl', () {
    late HttpServer server;
    late GeneratedApiClient apiClient;
    late OrderResponseComparisonRemoteDataSourceImpl dataSource;

    const accessToken = 'order-comparison-test-token';

    const orderId = '11111111-1111-4111-8111-111111111111';
    const itemId = '22222222-2222-4222-8222-222222222222';
    const recipientId = '33333333-3333-4333-8333-333333333333';
    const supplierId = '44444444-4444-4444-8444-444444444444';
    const recipientItemId = '55555555-5555-4555-8555-555555555555';
    const responseItemId = '66666666-6666-4666-8666-666666666666';
    const selectionId = '77777777-7777-4777-8777-777777777777';

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
      apiClient.setAccessToken(accessToken);

      dataSource = OrderResponseComparisonRemoteDataSourceImpl(apiClient);
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test(
      'show sends owned-order GET and deserializes nullable fields',
      () async {
        final requestFuture = server.first;

        final resultFuture = dataSource.show(orderId: '  $orderId  ');

        final request = await requestFuture;

        expect(request.method, 'GET');

        expect(request.uri.path, '/api/v1/orders/$orderId/supplier-responses');

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $accessToken',
        );

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;

        request.response.write(
          jsonEncode(
            _comparisonResponse(
              orderId: orderId,
              itemId: itemId,
              recipientId: recipientId,
              supplierId: supplierId,
              recipientItemId: recipientItemId,
              responseItemId: responseItemId,
              version: 1,
              selection: null,
            ),
          ),
        );

        await request.response.close();

        final result = await resultFuture;

        expect(result.id, orderId);
        expect(result.version, 1);
        expect(result.notes, isNull);
        expect(result.items, hasLength(1));

        final item = result.items.single;

        expect(item.id, itemId);
        expect(item.supplier.supplierId, supplierId);
        expect(item.selection, isNull);
        expect(item.response, isNotNull);
        expect(item.response!.availableQuantity, 2);
        expect(item.response!.offeredUnitPrice, '11.25');
      },
    );

    test(
      'replaceSelections sends expected_version and selections only',
      () async {
        final requestFuture = server.first;

        final resultFuture = dataSource.replaceSelections(
          orderId: orderId,
          expectedVersion: 1,
          selections: const [
            OrderResponseSelectionInput(
              orderRecipientItemResponseId: responseItemId,
              selectedQuantity: 1,
            ),
          ],
        );

        final request = await requestFuture;

        expect(request.method, 'PUT');

        expect(request.uri.path, '/api/v1/orders/$orderId/supplier-selection');

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $accessToken',
        );

        final rawBody = await utf8.decoder.bind(request).join();
        final body = jsonDecode(rawBody) as Map<String, dynamic>;

        expect(body.keys.toSet(), <String>{'expected_version', 'selections'});

        expect(body['expected_version'], 1);

        final selections = body['selections'] as List<dynamic>;

        expect(selections, hasLength(1));

        final selection = selections.single as Map<String, dynamic>;

        expect(selection.keys.toSet(), <String>{
          'order_recipient_item_response_id',
          'selected_quantity',
        });

        expect(selection['order_recipient_item_response_id'], responseItemId);
        expect(selection['selected_quantity'], 1);

        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;

        request.response.write(
          jsonEncode(
            _comparisonResponse(
              orderId: orderId,
              itemId: itemId,
              recipientId: recipientId,
              supplierId: supplierId,
              recipientItemId: recipientItemId,
              responseItemId: responseItemId,
              version: 2,
              selection: {
                'id': selectionId,
                'order_recipient_item_response_id': responseItemId,
                'selected_quantity': 1,
              },
            ),
          ),
        );

        await request.response.close();

        final result = await resultFuture;

        expect(result.version, 2);
        expect(result.items.single.selection, isNotNull);

        expect(result.items.single.selection!.selectedQuantity, 1);
      },
    );

    test(
      'replaceSelections maps HTTP 409 to stale version exception',
      () async {
        final requestFuture = server.first;

        final resultFuture = dataSource.replaceSelections(
          orderId: orderId,
          expectedVersion: 1,
          selections: const [
            OrderResponseSelectionInput(
              orderRecipientItemResponseId: responseItemId,
              selectedQuantity: 1,
            ),
          ],
        );

        final request = await requestFuture;

        request.response.statusCode = HttpStatus.conflict;
        request.response.headers.contentType = ContentType.json;

        request.response.write(
          jsonEncode({'message': 'The order version is stale.'}),
        );

        await request.response.close();

        await expectLater(
          resultFuture,
          throwsA(isA<StaleOrderVersionException>()),
        );
      },
    );
  });
}

Map<String, dynamic> _comparisonResponse({
  required String orderId,
  required String itemId,
  required String recipientId,
  required String supplierId,
  required String recipientItemId,
  required String responseItemId,
  required int version,
  required Map<String, dynamic>? selection,
}) {
  return {
    'data': {
      'id': orderId,
      'version': version,
      'status': 'pending',
      'notes': null,
      'items': [
        {
          'id': itemId,
          'product_id': 'product-1',
          'product_name': 'Product One',
          'requested_quantity': 3,
          'order_unit_price': '12.50',
          'supplier': {
            'recipient_id': recipientId,
            'supplier_id': supplierId,
            'supplier_name': 'Supplier One',
          },
          'response': {
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
          'selection': selection,
        },
      ],
      'created_at': '2026-08-30T01:00:00+03:00',
      'updated_at': '2026-08-30T01:10:00+03:00',
    },
  };
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/products/data/datasources/remote/products_remote_datasource.dart';

void main() {
  test(
    'loads all Products only from the requested Business endpoint',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      const token = 'supplier-management-token';
      const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      final requestedPages = <String?>[];

      final subscription = server.listen((request) async {
        expect(request.method, 'GET');

        expect(request.uri.path, '/api/v1/businesses/$businessId/products');

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $token',
        );

        expect(request.uri.queryParameters['per_page'], '100');

        final pageText = request.uri.queryParameters['page'];

        requestedPages.add(pageText);

        final page = int.parse(pageText!);

        final products = page == 1
            ? <Map<String, dynamic>>[
                _productJson(
                  id: '11111111-1111-4111-8111-111111111111',
                  businessId: businessId,
                  name: 'Managed One',
                  version: 3,
                ),
              ]
            : <Map<String, dynamic>>[
                _productJson(
                  id: '22222222-2222-4222-8222-222222222222',
                  businessId: businessId,
                  name: 'Managed Two',
                  version: 4,
                ),
              ];

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode(
              _pageEnvelope(
                baseUrl: baseUrl,
                businessId: businessId,
                page: page,
                lastPage: 2,
                products: products,
              ),
            ),
          );

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

      apiClient.setAccessToken(token);

      final source = ProductsRemoteDataSource(apiClient);

      final products = await source.getBusinessProducts(businessId);

      expect(requestedPages, <String?>['1', '2']);

      expect(products, hasLength(2));
      expect(products[0].supplierId, businessId);
      expect(products[1].supplierId, businessId);
      expect(products[0].serverVersion, 3);
      expect(products[1].serverVersion, 4);
    },
  );
}

Map<String, dynamic> _productJson({
  required String id,
  required String businessId,
  required String name,
  required int version,
}) {
  return <String, dynamic>{
    'id': id,
    'supplier_id': businessId,
    'supplier_name': 'Managed Supplier',
    'name': name,
    'description': 'Management Product',
    'category': 'Tests',
    'brand': 'Talbatiyk',
    'price': 100,
    'quantity': 10,
    'is_available': true,
    'image_url': null,
    'colors': <String>[],
    'discount': 0,
    'rating': 0,
    'created_at': '2026-10-06T00:00:00+00:00',
    'version': version,
    'updated_at': '2026-10-06T00:00:00+00:00',
  };
}

Map<String, dynamic> _pageEnvelope({
  required String baseUrl,
  required String businessId,
  required int page,
  required int lastPage,
  required List<Map<String, dynamic>> products,
}) {
  final endpoint = '$baseUrl/businesses/$businessId/products';

  final previous = page > 1 ? page - 1 : null;
  final next = page < lastPage ? page + 1 : null;

  return <String, dynamic>{
    'data': products,
    'links': <String, dynamic>{
      'first': '$endpoint?page=1',
      'last': '$endpoint?page=$lastPage',
      'prev': previous == null ? null : '$endpoint?page=$previous',
      'next': next == null ? null : '$endpoint?page=$next',
    },
    'meta': <String, dynamic>{
      'current_page': page,
      'from': products.isEmpty ? null : page,
      'last_page': lastPage,
      'links': <Map<String, dynamic>>[
        <String, dynamic>{
          'url': previous == null ? null : '$endpoint?page=$previous',
          'label': 'Previous',
          'active': false,
        },
        <String, dynamic>{
          'url': '$endpoint?page=$page',
          'label': '$page',
          'active': true,
        },
        <String, dynamic>{
          'url': next == null ? null : '$endpoint?page=$next',
          'label': 'Next',
          'active': false,
        },
      ],
      'per_page': 100,
      'to': products.isEmpty ? null : page,
      'total': 2,
    },
  };
}

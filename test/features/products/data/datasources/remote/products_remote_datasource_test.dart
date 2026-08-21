import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/products/data/datasources/remote/products_remote_datasource.dart';

void main() {
  group('ProductsRemoteDataSource', () {
    test(
      'fetches all pages with bearer token and maps generated resources',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        const accessToken = 'products-test-access-token';
        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final requestedPages = <String?>[];

        final subscription = server.listen((request) async {
          expect(request.method, 'GET');
          expect(request.uri.path, '/api/v1/products');

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer $accessToken',
          );

          expect(request.uri.queryParameters['per_page'], '100');

          final pageText = request.uri.queryParameters['page'];
          requestedPages.add(pageText);

          final page = int.parse(pageText!);

          final products = switch (page) {
            1 => <Map<String, dynamic>>[
              _productJson(
                id: '11111111-1111-4111-8111-111111111111',
                supplierId: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
                supplierName: 'Supplier One',
                name: 'Headphones',
                price: 150.5,
                quantity: 3,
                isAvailable: true,
                description: null,
                imageUrl: null,
                colors: const ['Black', 'White'],
                discount: 5,
                rating: 4.5,
                createdAt: '2026-08-21T10:00:00+03:00',
              ),
            ],
            2 => <Map<String, dynamic>>[
              _productJson(
                id: '22222222-2222-4222-8222-222222222222',
                supplierId: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
                supplierName: 'Supplier Two',
                name: 'Keyboard',
                price: 80,
                quantity: 0,
                isAvailable: false,
                description: 'Mechanical keyboard',
                imageUrl: 'https://example.test/keyboard.jpg',
                colors: const ['Blue'],
                discount: 0,
                rating: 0,
                createdAt: null,
              ),
            ],
            _ => throw StateError('Unexpected requested page: $page'),
          };

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(
                _pageEnvelope(
                  baseUrl: baseUrl,
                  page: page,
                  lastPage: 2,
                  total: 2,
                  products: products,
                ),
              ),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
        apiClient.setAccessToken(accessToken);

        final dataSource = ProductsRemoteDataSource(apiClient);

        final products = await dataSource.getProducts();

        expect(requestedPages, ['1', '2']);

        expect(products, hasLength(2));

        final first = products[0];

        expect(first.id, '11111111-1111-4111-8111-111111111111');
        expect(first.supplierId, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');
        expect(first.supplierName, 'Supplier One');
        expect(first.name, 'Headphones');
        expect(first.price, 150.5);
        expect(first.quantity, 3);
        expect(first.isAvailable, isTrue);
        expect(first.description, '');
        expect(first.imageUrl, '');
        expect(first.colors, ['Black', 'White']);
        expect(first.discount, 5);
        expect(first.rating, 4.5);
        expect(first.createdAt, DateTime.parse('2026-08-21T10:00:00+03:00'));

        final second = products[1];

        expect(second.id, '22222222-2222-4222-8222-222222222222');
        expect(second.supplierName, 'Supplier Two');
        expect(second.name, 'Keyboard');
        expect(second.price, 80);
        expect(second.quantity, 0);
        expect(second.isAvailable, isFalse);
        expect(second.description, 'Mechanical keyboard');
        expect(second.imageUrl, 'https://example.test/keyboard.jpg');
        expect(second.colors, ['Blue']);
      },
    );
  });
}

Map<String, dynamic> _productJson({
  required String id,
  required String supplierId,
  required String supplierName,
  required String name,
  required num price,
  required int quantity,
  required bool isAvailable,
  required String? description,
  required String? imageUrl,
  required List<String> colors,
  required num discount,
  required num rating,
  required String? createdAt,
}) {
  return <String, dynamic>{
    'id': id,
    'supplier_id': supplierId,
    'supplier_name': supplierName,
    'name': name,
    'description': description,
    'category': 'Electronics',
    'brand': 'Test Brand',
    'price': price,
    'quantity': quantity,
    'is_available': isAvailable,
    'image_url': imageUrl,
    'colors': colors,
    'discount': discount,
    'rating': rating,
    'created_at': createdAt,
    'updated_at': createdAt,
  };
}

Map<String, dynamic> _pageEnvelope({
  required String baseUrl,
  required int page,
  required int lastPage,
  required int total,
  required List<Map<String, dynamic>> products,
}) {
  final previousPage = page > 1 ? page - 1 : null;
  final nextPage = page < lastPage ? page + 1 : null;

  return <String, dynamic>{
    'data': products,
    'links': <String, dynamic>{
      'first': '$baseUrl/products?page=1',
      'last': '$baseUrl/products?page=$lastPage',
      'prev': previousPage == null
          ? null
          : '$baseUrl/products?page=$previousPage',
      'next': nextPage == null ? null : '$baseUrl/products?page=$nextPage',
    },
    'meta': <String, dynamic>{
      'current_page': page,
      'from': products.isEmpty ? null : page,
      'last_page': lastPage,
      'links': <Map<String, dynamic>>[
        <String, dynamic>{
          'url': previousPage == null
              ? null
              : '$baseUrl/products?page=$previousPage',
          'label': 'Previous',
          'active': false,
        },
        <String, dynamic>{
          'url': '$baseUrl/products?page=$page',
          'label': '$page',
          'active': true,
        },
        <String, dynamic>{
          'url': nextPage == null ? null : '$baseUrl/products?page=$nextPage',
          'label': 'Next',
          'active': false,
        },
      ],
      'per_page': 100,
      'to': products.isEmpty ? null : page,
      'total': total,
    },
  };
}

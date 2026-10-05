import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/products/data/datasources/remote/products_remote_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

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

    test('sends metadata update through generated PUT contract', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      const accessToken = 'mutation-access-token';
      const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
      const productId = '11111111-1111-4111-8111-111111111111';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      String? receivedMethod;
      String? receivedPath;
      String? receivedAuthorization;
      String? receivedContentType;
      String? receivedBody;

      final subscription = server.listen((request) async {
        receivedMethod = request.method;
        receivedPath = request.uri.path;
        receivedAuthorization = request.headers.value(
          HttpHeaders.authorizationHeader,
        );
        receivedContentType = request.headers.value(
          HttpHeaders.contentTypeHeader,
        );

        final bytes = <int>[];

        await for (final chunk in request) {
          bytes.addAll(chunk);
        }

        receivedBody = utf8.decode(bytes);

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode(<String, dynamic>{
              'data': _productJson(
                id: productId,
                supplierId: businessId,
                supplierName: 'Mutation Supplier',
                name: 'Updated Product',
                price: 150.25,
                quantity: 1000000,
                isAvailable: false,
                description: 'Updated description',
                imageUrl: null,
                colors: const <String>[],
                discount: 0,
                rating: 0,
                createdAt: '2026-10-04T12:00:00+00:00',
                version: 8,
              ),
            }),
          );

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
      apiClient.setAccessToken(accessToken);

      final dataSource = ProductsRemoteDataSource(apiClient);

      final product = ProductModel(
        id: productId,
        supplierId: businessId,
        supplierName: 'Mutation Supplier',
        name: 'Updated Product',
        price: 150.25,
        imageUrl: 'https://example.test/old-product.jpg',
        category: 'Electronics',
        brand: 'Test Brand',
        isAvailable: false,
        description: 'Updated description',
        quantity: 1000000,
      );

      final updated = await dataSource.updateProductMutation(
        product,
        expectedVersion: 7,
        removeImage: true,
      );

      expect(receivedMethod, 'PUT');

      expect(
        receivedPath,
        '/api/v1/businesses/$businessId/products/$productId',
      );

      expect(receivedAuthorization, 'Bearer $accessToken');

      expect(receivedContentType, contains('application/json'));

      expect(receivedBody, isNotNull);

      final decoded = jsonDecode(receivedBody!) as Map<String, dynamic>;

      expect(decoded, <String, dynamic>{
        'expected_version': 7,
        'name': 'Updated Product',
        'description': 'Updated description',
        'category': 'Electronics',
        'brand': 'Test Brand',
        'price': 150.25,
        'quantity': 1000000,
        'is_available': false,
        'remove_image': true,
      });

      expect(updated.id, productId);
      expect(updated.serverVersion, 8);
      expect(updated.imageUrl, '');
      expect(updated.quantity, 1000000);
    });

    test(
      'sends image replacement through generated multipart contract',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        final tempDirectory = await Directory.systemTemp.createTemp(
          'talbatiyk-product-mutation-image-',
        );

        addTearDown(() async {
          if (await tempDirectory.exists()) {
            await tempDirectory.delete(recursive: true);
          }
        });

        final image = File(
          '${tempDirectory.path}${Platform.pathSeparator}replacement.jpg',
        );

        await image.writeAsBytes(
          utf8.encode('replacement-image-content'),
          flush: true,
        );

        const accessToken = 'mutation-image-access-token';
        const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
        const productId = '22222222-2222-4222-8222-222222222222';

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        String? receivedMethod;
        String? receivedPath;
        String? receivedAuthorization;
        String? receivedContentType;
        String? receivedBody;

        final subscription = server.listen((request) async {
          receivedMethod = request.method;
          receivedPath = request.uri.path;
          receivedAuthorization = request.headers.value(
            HttpHeaders.authorizationHeader,
          );
          receivedContentType = request.headers.value(
            HttpHeaders.contentTypeHeader,
          );

          final bytes = <int>[];

          await for (final chunk in request) {
            bytes.addAll(chunk);
          }

          receivedBody = latin1.decode(bytes);

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': _productJson(
                  id: productId,
                  supplierId: businessId,
                  supplierName: 'Mutation Supplier',
                  name: 'Image Product',
                  price: 200,
                  quantity: 4,
                  isAvailable: true,
                  description: 'Image mutation',
                  imageUrl:
                      '$baseUrl/storage/products/$businessId/replacement.jpg',
                  colors: const <String>[],
                  discount: 0,
                  rating: 0,
                  createdAt: '2026-10-04T12:00:00+00:00',
                  version: 9,
                ),
              }),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
        apiClient.setAccessToken(accessToken);

        final dataSource = ProductsRemoteDataSource(apiClient);

        final updated = await dataSource.updateProductImageMutation(
          businessId: businessId,
          productId: productId,
          expectedVersion: 8,
          localImagePath: image.path,
        );

        expect(receivedMethod, 'POST');

        expect(
          receivedPath,
          '/api/v1/businesses/$businessId/products/$productId/image',
        );

        expect(receivedAuthorization, 'Bearer $accessToken');

        expect(receivedContentType, contains('multipart/form-data'));

        expect(receivedBody, isNotNull);

        expect(receivedBody, contains('name="expected_version"'));

        expect(receivedBody, contains('name="image"'));

        expect(receivedBody, contains('filename="replacement.jpg"'));

        expect(receivedBody, contains('replacement-image-content'));

        expect(
          RegExp(
            r'name="expected_version"\r\n\r\n8\r\n',
          ).hasMatch(receivedBody!),
          isTrue,
        );

        expect(updated.id, productId);
        expect(updated.serverVersion, 9);

        expect(
          updated.imageUrl,
          '$baseUrl/storage/products/$businessId/replacement.jpg',
        );
      },
    );

    test('sends delete through generated DELETE query contract', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      const accessToken = 'mutation-delete-access-token';
      const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
      const productId = '33333333-3333-4333-8333-333333333333';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      String? receivedMethod;
      String? receivedPath;
      String? receivedAuthorization;
      Map<String, String>? receivedQuery;

      final subscription = server.listen((request) async {
        receivedMethod = request.method;
        receivedPath = request.uri.path;
        receivedAuthorization = request.headers.value(
          HttpHeaders.authorizationHeader,
        );
        receivedQuery = Map<String, String>.from(request.uri.queryParameters);

        await request.drain<void>();

        request.response.statusCode = HttpStatus.noContent;

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
      apiClient.setAccessToken(accessToken);

      final dataSource = ProductsRemoteDataSource(apiClient);

      await dataSource.deleteProductMutation(
        businessId: businessId,
        productId: productId,
        expectedVersion: 11,
      );

      expect(receivedMethod, 'DELETE');

      expect(
        receivedPath,
        '/api/v1/businesses/$businessId/products/$productId',
      );

      expect(receivedAuthorization, 'Bearer $accessToken');

      expect(receivedQuery, <String, String>{'expected_version': '11'});
    });
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
  int version = 1,
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
    'version': version,
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

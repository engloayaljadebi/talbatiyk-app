import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/products/data/datasources/remote/products_remote_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

void main() {
  test(
    'publishes supplier product online as multipart and returns server product',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      final tempDirectory = await Directory.systemTemp.createTemp(
        'talbatiyk-product-publishing-',
      );

      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final image = File(
        '${tempDirectory.path}${Platform.pathSeparator}product.jpg',
      );

      await image.writeAsBytes(utf8.encode('test-image-content'), flush: true);

      const accessToken = 'publishing-access-token';
      const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
      const serverProductId = '11111111-1111-4111-8111-111111111111';
      const idempotencyKey = '22222222-2222-4222-8222-222222222222';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      String? receivedMethod;
      String? receivedPath;
      String? receivedAuthorization;
      String? receivedIdempotencyKey;
      String? receivedContentType;
      String? receivedBody;

      final requestCompleted = Completer<void>();

      final subscription = server.listen((request) async {
        try {
          receivedMethod = request.method;
          receivedPath = request.uri.path;
          receivedAuthorization = request.headers.value(
            HttpHeaders.authorizationHeader,
          );

          receivedIdempotencyKey = request.headers.value('Idempotency-Key');
          receivedContentType = request.headers.value(
            HttpHeaders.contentTypeHeader,
          );

          final bytes = <int>[];

          await for (final chunk in request) {
            bytes.addAll(chunk);
          }

          receivedBody = latin1.decode(bytes);

          request.response
            ..statusCode = HttpStatus.created
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': <String, dynamic>{
                  'id': serverProductId,
                  'supplier_id': businessId,
                  'supplier_name': 'Online Supplier',
                  'supplier_governorate': 'صنعاء',
                  'name': 'Online Flutter Product',
                  'description': 'Published directly from Flutter.',
                  'category': 'Electronics',
                  'brand': 'Talbatiyk Test',
                  'price': 1250.5,
                  'quantity': 8,
                  'is_available': true,
                  'image_url':
                      '$baseUrl/storage/products/'
                      '$businessId/product.jpg',
                  'colors': <String>[],
                  'discount': 0,
                  'rating': 0,
                  'created_at': '2026-09-25T02:00:00+00:00',
                  'updated_at': '2026-09-25T02:00:00+00:00',
                },
              }),
            );

          await request.response.close();
        } finally {
          if (!requestCompleted.isCompleted) {
            requestCompleted.complete();
          }
        }
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

      apiClient.setAccessToken(accessToken);

      final dataSource = ProductsRemoteDataSource(apiClient);

      final product = ProductModel(
        id: 'temporary-client-id',
        supplierId: businessId,
        supplierName: 'Online Supplier',
        name: 'Online Flutter Product',
        price: 1250.5,
        imageUrl: '',
        localImagePath: image.path,
        category: 'Electronics',
        brand: 'Talbatiyk Test',
        isAvailable: true,
        description: 'Published directly from Flutter.',
        quantity: 8,
      );

      final created = await dataSource.createProductIdempotently(
        product,
        idempotencyKey: idempotencyKey,
      );

      await requestCompleted.future;

      expect(receivedMethod, 'POST');

      expect(receivedPath, '/api/v1/businesses/$businessId/products');

      expect(receivedAuthorization, 'Bearer $accessToken');
      expect(receivedIdempotencyKey, idempotencyKey);
      expect(receivedContentType, startsWith('multipart/form-data'));

      expect(receivedBody, contains('Online Flutter Product'));

      expect(receivedBody, contains('Electronics'));

      expect(receivedBody, contains('Talbatiyk Test'));

      expect(receivedBody, contains('product.jpg'));

      expect(receivedBody, contains('test-image-content'));

      expect(created.id, serverProductId);
      expect(created.supplierId, businessId);
      expect(created.supplierName, 'Online Supplier');
      expect(created.supplierGovernorate, 'صنعاء');
      expect(created.name, 'Online Flutter Product');
      expect(created.price, 1250.5);
      expect(created.quantity, 8);
      expect(created.isAvailable, isTrue);

      expect(
        created.imageUrl,
        '$baseUrl/storage/products/'
        '$businessId/product.jpg',
      );

      /*
       * المعرف المؤقت في الهاتف لا يصبح معرف المنتج النهائي.
       * السيرفر هو مصدر معرف المنتج المنشور.
       */
      expect(created.id, isNot(product.id));
    },
  );
}

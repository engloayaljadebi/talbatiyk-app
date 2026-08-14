/*
|--------------------------------------------------------------------------
| Business Remote Data Source Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار جلب قائمة الأنشطة عبر GET /businesses.
| - اختبار جلب نشاط واحد عبر GET /businesses/{business}.
| - اختبار رفض Business ID الفارغ قبل الاتصال بالشبكة.
| - اختبار إنشاء نشاط عبر POST /businesses.
| - التحقق من Bearer Token المرسل مع الطلبات المحمية.
| - التحقق من JSON الفعلي المرسل بواسطة Generated OpenAPI Client.
|
| الهدف:
| اختبار BusinessRemoteDataSource مع Generated Dart-Dio Client
| باستخدام HttpServer محلي دون الاتصال بـLaravel الحقيقي.
|
*/

import 'dart:convert';
import 'dart:io';

import 'package:built_collection/built_collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/business/data/datasources/remote/business_remote_datasource.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

void main() {
  group('BusinessRemoteDataSourceImpl', () {
    late HttpServer server;
    late GeneratedApiClient apiClient;
    late BusinessRemoteDataSourceImpl dataSource;

    const accessToken = 'business-test-access-token';

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

      apiClient.setAccessToken(accessToken);

      dataSource = BusinessRemoteDataSourceImpl(apiClient);
    });

    tearDown(() async {
      await server.close(force: true);
    });

    test(
      'index sends GET /businesses with bearer token and returns businesses',
      () async {
        final requestFuture = server.first;

        final resultFuture = dataSource.index();

        final request = await requestFuture;

        expect(request.method, 'GET');

        expect(request.uri.path, '/api/v1/businesses');

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
                'id': '11111111-1111-4111-8111-111111111111',
                'name': 'Business One',
                'status': 'active',
              },
              {
                'id': '22222222-2222-4222-8222-222222222222',
                'name': 'Business Two',
                'status': 'active',
              },
            ],
          }),
        );

        await request.response.close();

        final result = await resultFuture;

        expect(result, isA<BuiltList<BusinessResource>>());

        expect(result.length, 2);

        expect(result.first.id, '11111111-1111-4111-8111-111111111111');

        expect(result.first.name, 'Business One');

        expect(result.first.status, 'active');

        expect(result.last.id, '22222222-2222-4222-8222-222222222222');

        expect(result.last.name, 'Business Two');
      },
    );

    test('show sends GET /businesses/{business} with normalized id', () async {
      const businessId = '11111111-1111-4111-8111-111111111111';

      final requestFuture = server.first;

      final resultFuture = dataSource.show(businessId: '  $businessId  ');

      final request = await requestFuture;

      expect(request.method, 'GET');

      expect(request.uri.path, '/api/v1/businesses/$businessId');

      expect(
        request.headers.value(HttpHeaders.authorizationHeader),
        'Bearer $accessToken',
      );

      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;

      request.response.write(
        jsonEncode({
          'data': {
            'id': businessId,
            'name': 'Business Details',
            'legal_name': 'Business Details LLC',
            'description': 'Business description',
            'status': 'active',
            'created_at': '2026-08-13T10:00:00+03:00',
            'updated_at': '2026-08-13T11:00:00+03:00',
          },
        }),
      );

      await request.response.close();

      final result = await resultFuture;

      expect(result.id, businessId);

      expect(result.name, 'Business Details');

      expect(result.legalName, 'Business Details LLC');

      expect(result.description, 'Business description');

      expect(result.status, 'active');

      expect(result.createdAt, '2026-08-13T10:00:00+03:00');

      expect(result.updatedAt, '2026-08-13T11:00:00+03:00');
    });

    test('show rejects empty business id before sending request', () async {
      await expectLater(
        dataSource.show(businessId: '   '),
        throwsA(isA<ArgumentError>()),
      );
    });

    test(
      'store sends POST /businesses with bearer token and expected json',
      () async {
        final location = CreateBusinessRequestLocation(
          (builder) => builder
            ..name = 'Main Store'
            ..type = CreateBusinessRequestLocationTypeEnum.store
            ..timezone = 'Asia/Aden'
            ..countryCode = 'YE'
            ..administrativeArea = 'Aden'
            ..locality = 'Aden'
            ..district = 'Al Mansoura'
            ..streetAddress = 'Main Street'
            ..addressNotes = 'Near the market'
            ..latitude = 12.7855
            ..longitude = 45.0187,
        );

        final contact = CreateBusinessRequestContact(
          (builder) => builder
            ..type = CreateBusinessRequestContactTypeEnum.phone
            ..value = '+967777123456'
            ..label = 'Primary Phone',
        );

        final createRequest = CreateBusinessRequest(
          (builder) => builder
            ..name = 'Talbatiyk Test Business'
            ..legalName = 'Talbatiyk Test Business LLC'
            ..description = 'Business created from Flutter test'
            ..capabilities.replace(BuiltList<String>(['supplier', 'shop']))
            ..location.replace(location)
            ..contact.replace(contact),
        );

        final requestFuture = server.first;

        final resultFuture = dataSource.store(request: createRequest);

        final request = await requestFuture;

        expect(request.method, 'POST');

        expect(request.uri.path, '/api/v1/businesses');

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $accessToken',
        );

        final rawBody = await utf8.decoder.bind(request).join();

        final requestBody = jsonDecode(rawBody) as Map<String, dynamic>;

        expect(requestBody['name'], 'Talbatiyk Test Business');

        expect(requestBody['legal_name'], 'Talbatiyk Test Business LLC');

        expect(
          requestBody['description'],
          'Business created from Flutter test',
        );

        expect(requestBody['capabilities'], ['supplier', 'shop']);

        final locationBody = requestBody['location'] as Map<String, dynamic>;

        expect(locationBody['name'], 'Main Store');

        expect(locationBody['type'], 'store');

        expect(locationBody['timezone'], 'Asia/Aden');

        expect(locationBody['country_code'], 'YE');

        expect(locationBody['administrative_area'], 'Aden');

        expect(locationBody['locality'], 'Aden');

        expect(locationBody['district'], 'Al Mansoura');

        expect(locationBody['street_address'], 'Main Street');

        expect(locationBody['address_notes'], 'Near the market');

        expect(locationBody['latitude'], 12.7855);

        expect(locationBody['longitude'], 45.0187);

        final contactBody = requestBody['contact'] as Map<String, dynamic>;

        expect(contactBody['type'], 'phone');

        expect(contactBody['value'], '+967777123456');

        expect(contactBody['label'], 'Primary Phone');

        request.response.statusCode = HttpStatus.created;
        request.response.headers.contentType = ContentType.json;

        request.response.write(
          jsonEncode({
            'data': {
              'id': '33333333-3333-4333-8333-333333333333',
              'name': 'Talbatiyk Test Business',
              'legal_name': 'Talbatiyk Test Business LLC',
              'description': 'Business created from Flutter test',
              'status': 'active',
              'created_at': '2026-08-13T12:00:00+03:00',
              'updated_at': '2026-08-13T12:00:00+03:00',
            },
          }),
        );

        await request.response.close();

        final result = await resultFuture;

        expect(result.id, '33333333-3333-4333-8333-333333333333');

        expect(result.name, 'Talbatiyk Test Business');

        expect(result.legalName, 'Talbatiyk Test Business LLC');

        expect(result.description, 'Business created from Flutter test');

        expect(result.status, 'active');
      },
    );
  });
}

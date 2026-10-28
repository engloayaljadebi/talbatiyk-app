/*
|--------------------------------------------------------------------------
| Auth Remote Data Source Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار تسجيل الدخول عبر Generated OpenAPI Client.
| - التحقق من بيانات LoginRequest المرسلة إلى Laravel.
| - التحقق من ربط Bearer Token بعد تسجيل الدخول.
| - اختبار جلب المستخدم الحالي عبر /auth/me.
| - التحقق من إرسال Authorization Bearer Token.
| - اختبار تسجيل الخروج عبر /auth/logout.
| - التحقق من إزالة Bearer Token بعد نجاح تسجيل الخروج.
|
| تعتمد الاختبارات على HttpServer محلي ولا تحتاج Mockito.
|
*/

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

void main() {
  const userId = '11111111-1111-4111-8111-111111111111';

  Map<String, dynamic> userJson() {
    return <String, dynamic>{
      'id': userId,
      'username': 'test_user',
      'display_name': 'Test User',
      'status': 'active',
      'last_login_at': null,
      'contacts': <dynamic>[],
    };
  }

  group('AuthRemoteDataSourceImpl', () {
    test('registration categories can be loaded without a token', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async => server.close(force: true));

      final handled = server.first.then((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/api/v1/auth/registration-categories');
        expect(request.headers.value(HttpHeaders.authorizationHeader), isNull);

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'data': [
                {
                  'id': '11111111-1111-4111-8111-111111111111',
                  'name': 'مواد غذائية',
                },
              ],
            }),
          );

        await request.response.close();
      });

      final client = GeneratedApiClient.create(
        baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
      );

      final categories = await AuthRemoteDataSourceImpl(
        client,
      ).fetchRegistrationCategories();

      await handled;

      expect(categories, hasLength(1));
      expect(categories.single.name, 'مواد غذائية');
      expect(categories.single.id, '11111111-1111-4111-8111-111111111111');
    });

    test('mobile registration submits account and business data', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() async => server.close(force: true));

      Map<String, dynamic>? received;

      final handled = server.first.then((request) async {
        expect(request.method, 'POST');
        expect(request.uri.path, '/api/v1/auth/register');

        received =
            jsonDecode(await utf8.decoder.bind(request).join())
                as Map<String, dynamic>;

        request.response
          ..statusCode = HttpStatus.created
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'data': {
                'user': userJson(),
                'business': null,
                'access_token': 'registration-test-token',
                'token_type': 'Bearer',
              },
            }),
          );

        await request.response.close();
      });

      final client = GeneratedApiClient.create(
        baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
      );

      final result = await AuthRemoteDataSourceImpl(client).registerFromMobile({
        'account_type': 'supplier',
        'username': 'supplier123',
        'display_name': 'Test Supplier',
        'password': 'StrongPass123!',
        'password_confirmation': 'StrongPass123!',
        'contact_type': 'phone',
        'contact_value': '012345678',
        'device_name': 'Android',
        'name': 'Test Business',
        'category_id': '11111111-1111-4111-8111-111111111111',
        'location_name': 'Main Location',
        'administrative_area': 'Sanaa',
        'locality': 'Sanaa',
      });

      await handled;

      expect(received?['account_type'], 'supplier');
      expect(received?['username'], 'supplier123');
      expect(received?['contact_value'], '012345678');
      expect(received?['name'], 'Test Business');
      expect(result.accessToken, 'registration-test-token');

      final bearer = client.client.dio.interceptors
          .whereType<BearerAuthInterceptor>()
          .single;

      expect(bearer.tokens['http'], 'registration-test-token');
    });

    test(
      'login sends correct request, returns session, and sets bearer token',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        Map<String, dynamic>? receivedBody;

        final requestHandled = server.first.then((request) async {
          expect(request.method, 'POST');
          expect(request.uri.path, '/api/v1/auth/login');

          final rawBody = await utf8.decoder.bind(request).join();

          receivedBody = jsonDecode(rawBody) as Map<String, dynamic>;

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': <String, dynamic>{
                  'user': userJson(),
                  'access_token': 'test-access-token',
                  'token_type': 'Bearer',
                },
              }),
            );

          await request.response.close();
        });

        final apiClient = GeneratedApiClient.create(
          baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
        );

        final dataSource = AuthRemoteDataSourceImpl(apiClient);

        final session = await dataSource.login(
          login: 'test_user',
          password: 'secret123',
          deviceName: 'flutter-test',
        );

        await requestHandled;

        expect(receivedBody, <String, dynamic>{
          'login': 'test_user',
          'password': 'secret123',
          'device_name': 'flutter-test',
        });

        expect(session.accessToken, 'test-access-token');
        expect(session.user.id, userId);
        expect(session.user.username, 'test_user');

        final bearerInterceptor = apiClient.client.dio.interceptors
            .whereType<BearerAuthInterceptor>()
            .single;

        expect(bearerInterceptor.tokens['http'], 'test-access-token');
      },
    );

    test('me sends bearer token and returns current user', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      final requestHandled = server.first.then((request) async {
        expect(request.method, 'GET');
        expect(request.uri.path, '/api/v1/auth/me');

        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer test-me-token',
        );

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(<String, dynamic>{'data': userJson()}));

        await request.response.close();
      });

      final apiClient = GeneratedApiClient.create(
        baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
      );

      apiClient.setAccessToken('test-me-token');

      final dataSource = AuthRemoteDataSourceImpl(apiClient);

      final user = await dataSource.me();

      await requestHandled;

      expect(user.id, userId);
      expect(user.username, 'test_user');
      expect(user.displayName, 'Test User');
    });

    test(
      'logout sends bearer token and clears it after server success',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        final requestHandled = server.first.then((request) async {
          expect(request.method, 'POST');
          expect(request.uri.path, '/api/v1/auth/logout');

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer test-logout-token',
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'message': 'تم تسجيل الخروج بنجاح.',
              }),
            );

          await request.response.close();
        });

        final apiClient = GeneratedApiClient.create(
          baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
        );

        apiClient.setAccessToken('test-logout-token');

        final bearerInterceptor = apiClient.client.dio.interceptors
            .whereType<BearerAuthInterceptor>()
            .single;

        expect(bearerInterceptor.tokens['http'], 'test-logout-token');

        final dataSource = AuthRemoteDataSourceImpl(apiClient);

        await dataSource.logout();
        await requestHandled;

        expect(bearerInterceptor.tokens.containsKey('http'), isFalse);
      },
    );
  });
}

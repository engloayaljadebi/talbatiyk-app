import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';

void main() {
  const String userId = '11111111-1111-4111-8111-111111111111';

  Map<String, dynamic> userJson({
    required String username,
    required String displayName,
  }) {
    return <String, dynamic>{
      'id': userId,
      'username': username,
      'display_name': displayName,
      'status': 'active',
      'last_login_at': null,
      'contacts': <dynamic>[],
    };
  }

  group('Auth profile update remote contract', () {
    test(
      'updateProfile sends authenticated PATCH identity body and returns user',
      () async {
        final HttpServer server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          0,
        );

        addTearDown(() async {
          await server.close(force: true);
        });

        late Map<String, dynamic> receivedBody;

        final Future<void> requestHandled = server.first.then((
          HttpRequest request,
        ) async {
          expect(request.method, 'PATCH');

          expect(request.uri.path, '/api/v1/auth/me');

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer profile-update-token',
          );

          final String bodyText = await utf8.decoder.bind(request).join();

          receivedBody = jsonDecode(bodyText) as Map<String, dynamic>;

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': userJson(
                  username: 'new_username',
                  displayName: 'New Display Name',
                ),
              }),
            );

          await request.response.close();
        });

        final GeneratedApiClient apiClient = GeneratedApiClient.create(
          baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
        );

        apiClient.setAccessToken('profile-update-token');

        final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
          apiClient,
        );

        final user = await dataSource.updateProfile(
          username: 'new_username',
          displayName: 'New Display Name',
        );

        await requestHandled;

        expect(receivedBody, <String, dynamic>{
          'username': 'new_username',
          'display_name': 'New Display Name',
        });

        expect(user.id, userId);
        expect(user.username, 'new_username');

        expect(user.displayName, 'New Display Name');
      },
    );

    test(
      'updateProfile preserves PATCH semantics and omits absent username',
      () async {
        final HttpServer server = await HttpServer.bind(
          InternetAddress.loopbackIPv4,
          0,
        );

        addTearDown(() async {
          await server.close(force: true);
        });

        late Map<String, dynamic> receivedBody;

        final Future<void> requestHandled = server.first.then((
          HttpRequest request,
        ) async {
          expect(request.method, 'PATCH');

          expect(request.uri.path, '/api/v1/auth/me');

          final String bodyText = await utf8.decoder.bind(request).join();

          receivedBody = jsonDecode(bodyText) as Map<String, dynamic>;

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': userJson(
                  username: 'existing_username',
                  displayName: 'Renamed User',
                ),
              }),
            );

          await request.response.close();
        });

        final GeneratedApiClient apiClient = GeneratedApiClient.create(
          baseUrl: 'http://127.0.0.1:${server.port}/api/v1',
        );

        apiClient.setAccessToken('profile-update-token');

        final AuthRemoteDataSource dataSource = AuthRemoteDataSourceImpl(
          apiClient,
        );

        final user = await dataSource.updateProfile(
          displayName: 'Renamed User',
        );

        await requestHandled;

        expect(receivedBody, <String, dynamic>{'display_name': 'Renamed User'});

        expect(receivedBody.containsKey('username'), isFalse);

        expect(user.username, 'existing_username');

        expect(user.displayName, 'Renamed User');
      },
    );
  });
}

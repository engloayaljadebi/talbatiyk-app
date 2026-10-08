import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/business/data/datasources/remote/business_profile_remote_datasource.dart';
import 'package:talbatiyk/features/business/domain/entities/business_profile_update.dart';

void main() {
  test(
    'updateProfile preserves explicit null, bearer auth, and returns canonical business',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      const businessId = '11111111-1111-4111-8111-111111111111';

      const accessToken = 'supplier-profile-test-token';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      final requests = <_CapturedRequest>[];

      final subscription = server.listen((request) async {
        final bodyBytes = <int>[];

        await for (final chunk in request) {
          bodyBytes.addAll(chunk);
        }

        final body = bodyBytes.isEmpty ? null : utf8.decode(bodyBytes);

        requests.add(
          _CapturedRequest(
            method: request.method,
            path: request.uri.path,
            authorization: request.headers.value(
              HttpHeaders.authorizationHeader,
            ),
            contentType: request.headers.value(HttpHeaders.contentTypeHeader),
            body: body,
          ),
        );

        if (request.method == 'PATCH') {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode({
                'data': {
                  'id': businessId,
                  'name': 'الاسم المحدث',
                  'legal_name': null,
                  'description': null,
                  'status': 'active',
                  'capabilities': [],
                  'primary_location': null,
                  'primary_contact': null,
                  'membership': null,
                  'created_at': null,
                  'updated_at': null,
                },
              }),
            );

          await request.response.close();
          return;
        }

        if (request.method == 'GET') {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode({
                'data': {
                  'id': businessId,
                  'name': 'الاسم المحدث',
                  'legal_name': null,
                  'description': null,
                  'status': 'active',
                  'capabilities': [],
                  'primary_location': null,
                  'primary_contact': null,
                  'membership': null,
                  'created_at': null,
                  'updated_at': null,
                },
              }),
            );

          await request.response.close();
          return;
        }

        request.response.statusCode = HttpStatus.methodNotAllowed;

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

      apiClient.setAccessToken(accessToken);

      final dataSource = BusinessProfileRemoteDataSourceImpl(apiClient);

      final result = await dataSource.updateProfile(
        businessId: '  $businessId  ',
        update: const BusinessProfileUpdate(
          name: 'الاسم المحدث',
          legalName: PatchField<String>.present(null),
          description: PatchField<String>.present(null),
        ),
      );

      expect(requests, hasLength(2));

      final patch = requests[0];

      expect(patch.method, 'PATCH');
      expect(patch.path, '/api/v1/businesses/$businessId');

      expect(patch.authorization, 'Bearer $accessToken');

      expect(patch.contentType, contains('application/json'));

      final patchJson = jsonDecode(patch.body!) as Map<String, dynamic>;

      expect(patchJson, <String, Object?>{
        'name': 'الاسم المحدث',
        'legal_name': null,
        'description': null,
      });

      final get = requests[1];

      expect(get.method, 'GET');

      expect(get.path, '/api/v1/businesses/$businessId');

      expect(get.authorization, 'Bearer $accessToken');

      expect(result.id, businessId);
      expect(result.name, 'الاسم المحدث');
      expect(result.legalName, isNull);
      expect(result.description, isNull);
    },
  );
}

final class _CapturedRequest {
  const _CapturedRequest({
    required this.method,
    required this.path,
    required this.authorization,
    required this.contentType,
    required this.body,
  });

  final String method;
  final String path;
  final String? authorization;
  final String? contentType;
  final String? body;
}

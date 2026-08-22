import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/supplier_follow/data/datasources/supplier_follow_remote_datasource.dart';

void main() {
  group('SupplierFollowRemoteDataSourceImpl', () {
    test('reads follows and unfollows through generated client', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      const accessToken = 'follow-test-access-token';
      const businessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      final expectedMethods = <String>['GET', 'POST', 'DELETE'];
      final expectedStatuses = <bool>[false, true, false];
      final receivedMethods = <String>[];

      var requestIndex = 0;

      final subscription = server.listen((request) async {
        final index = requestIndex++;

        expect(index, lessThan(expectedMethods.length));
        expect(request.method, expectedMethods[index]);
        expect(request.uri.path, '/api/v1/businesses/$businessId/follow');
        expect(
          request.headers.value(HttpHeaders.authorizationHeader),
          'Bearer $accessToken',
        );

        receivedMethods.add(request.method);

        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'data': {
                'business_id': businessId,
                'is_following': expectedStatuses[index],
              },
            }),
          );

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);
      apiClient.setAccessToken(accessToken);

      final dataSource = SupplierFollowRemoteDataSourceImpl(apiClient);

      expect(await dataSource.isFollowing(businessId), isFalse);
      expect(await dataSource.follow(businessId), isTrue);
      expect(await dataSource.unfollow(businessId), isFalse);

      expect(receivedMethods, expectedMethods);
    });

    test('rejects response for a different business', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      const requestedBusinessId = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
      const responseBusinessId = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      final subscription = server.listen((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode({
              'data': {'business_id': responseBusinessId, 'is_following': true},
            }),
          );

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final dataSource = SupplierFollowRemoteDataSourceImpl(
        GeneratedApiClient.create(baseUrl: baseUrl),
      );

      await expectLater(
        dataSource.isFollowing(requestedBusinessId),
        throwsA(isA<StateError>()),
      );
    });
  });
}

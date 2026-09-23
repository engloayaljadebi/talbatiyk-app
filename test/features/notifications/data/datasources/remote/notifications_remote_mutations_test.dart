import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';

void main() {
  group('NotificationsRemoteDatasourceImpl mutations', () {
    test(
      'markRead calls the authenticated PATCH endpoint and returns the server notification',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        const accessToken = 'notifications-mutation-token';
        const notificationId = '11111111-1111-4111-8111-111111111111';

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final subscription = server.listen((request) async {
          expect(request.method, 'PATCH');

          expect(
            request.uri.path,
            '/api/v1/notifications/$notificationId/read',
          );

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer $accessToken',
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': _notificationJson(
                  id: notificationId,
                  isRead: true,
                  readAt: '2026-09-21T18:30:00Z',
                  updatedAt: '2026-09-21T18:30:00Z',
                ),
              }),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

        apiClient.setAccessToken(accessToken);

        final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

        final notification = await dataSource.markRead(
          notificationId: notificationId,
        );

        expect(notification.id, notificationId);
        expect(notification.isRead, isTrue);

        expect(notification.readAt, DateTime.utc(2026, 9, 21, 18, 30));

        expect(notification.updatedAt, DateTime.utc(2026, 9, 21, 18, 30));
      },
    );

    test(
      'markRead rejects a semantically invalid success response without read_at',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        const notificationId = '22222222-2222-4222-8222-222222222222';

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final subscription = server.listen((request) async {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(<String, dynamic>{
                'data': _notificationJson(
                  id: notificationId,
                  isRead: true,
                  readAt: null,
                  updatedAt: '2026-09-21T18:30:00Z',
                ),
              }),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

        final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

        await expectLater(
          dataSource.markRead(notificationId: notificationId),
          throwsA(isA<FormatException>()),
        );
      },
    );

    test(
      'markAllRead calls POST read-all and preserves both server counters',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        const accessToken = 'notifications-mark-all-token';

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final subscription = server.listen((request) async {
          expect(request.method, 'POST');

          expect(request.uri.path, '/api/v1/notifications/read-all');

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer $accessToken',
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(const <String, dynamic>{
                'data': <String, dynamic>{
                  'updated_count': 2,
                  'unread_count': 0,
                },
              }),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

        apiClient.setAccessToken(accessToken);

        final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

        final result = await dataSource.markAllRead();

        expect(result.updatedCount, 2);
        expect(result.unreadCount, 0);
      },
    );

    test(
      'getUnreadCount calls the authenticated unread-count endpoint',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        const accessToken = 'notifications-unread-token';

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final subscription = server.listen((request) async {
          expect(request.method, 'GET');

          expect(request.uri.path, '/api/v1/notifications/unread-count');

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer $accessToken',
          );

          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(const <String, dynamic>{
                'data': <String, dynamic>{'unread_count': 4},
              }),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

        apiClient.setAccessToken(accessToken);

        final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

        expect(await dataSource.getUnreadCount(), 4);
      },
    );
  });
}

Map<String, dynamic> _notificationJson({
  required String id,
  required bool isRead,
  required String? readAt,
  required String updatedAt,
}) {
  return <String, dynamic>{
    'id': id,
    'type': 'order_response_received',
    'title': 'Server notification',
    'body': 'Notification body',
    'data': <String, dynamic>{'order_id': 'order-1'},
    'is_read': isRead,
    'read_at': readAt,
    'created_at': '2026-09-21T18:00:00Z',
    'updated_at': updatedAt,
  };
}

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';

void main() {
  group('NotificationsRemoteDatasourceImpl', () {
    test(
      'fetches every notification page with bearer auth and maps the generated contract',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        const accessToken = 'notifications-test-access-token';

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final requestedPages = <String?>[];

        final subscription = server.listen((request) async {
          expect(request.method, 'GET');
          expect(request.uri.path, '/api/v1/notifications');

          expect(
            request.headers.value(HttpHeaders.authorizationHeader),
            'Bearer $accessToken',
          );

          expect(request.uri.queryParameters['per_page'], '100');

          final pageText = request.uri.queryParameters['page'];

          requestedPages.add(pageText);

          final page = int.parse(pageText!);

          final notifications = switch (page) {
            1 => <Map<String, dynamic>>[
              _notificationJson(
                id: '11111111-1111-4111-8111-111111111111',
                title: 'First version',
                isRead: false,
                readAt: null,
                createdAt: '2026-09-20T12:00:00+03:00',
                updatedAt: '2026-09-20T12:00:00+03:00',
                data: <String, dynamic>{
                  'order_id': 'order-1',
                  'attempt': 1,
                  'urgent': true,
                  'nullable': null,
                  'nested': <String, dynamic>{'supplier_id': 'supplier-1'},
                  'items': <Object?>['item-1', 2, false, null],
                },
              ),
              _notificationJson(
                id: '22222222-2222-4222-8222-222222222222',
                title: 'Older notification',
                isRead: false,
                readAt: null,
                createdAt: '2026-09-20T10:00:00Z',
                updatedAt: '2026-09-20T10:00:00Z',
                data: const <String, dynamic>{'order_id': 'order-2'},
              ),
            ],
            2 => <Map<String, dynamic>>[
              // Defensive duplicate: the later server representation wins.
              _notificationJson(
                id: '11111111-1111-4111-8111-111111111111',
                title: 'Latest version',
                isRead: true,
                readAt: '2026-09-20T12:30:00+03:00',
                createdAt: '2026-09-20T12:00:00+03:00',
                updatedAt: '2026-09-20T12:30:00+03:00',
                data: const <String, dynamic>{
                  'order_id': 'order-1',
                  'attempt': 2,
                },
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
                  total: 3,
                  notifications: notifications,
                ),
              ),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

        apiClient.setAccessToken(accessToken);

        final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

        final notifications = await dataSource.getNotifications();

        expect(requestedPages, <String?>['1', '2']);

        expect(notifications, hasLength(2));

        final latest = notifications.firstWhere(
          (notification) =>
              notification.id == '11111111-1111-4111-8111-111111111111',
        );

        expect(latest.title, 'Latest version');
        expect(latest.isRead, isTrue);

        expect(latest.readAt, DateTime.utc(2026, 9, 20, 9, 30));

        expect(latest.readAt!.isUtc, isTrue);

        expect(latest.createdAt, DateTime.utc(2026, 9, 20, 9));

        expect(latest.createdAt.isUtc, isTrue);

        expect(latest.updatedAt, DateTime.utc(2026, 9, 20, 9, 30));

        expect(latest.updatedAt.isUtc, isTrue);

        expect(latest.data, <String, dynamic>{
          'order_id': 'order-1',
          'attempt': 2,
        });

        final older = notifications.firstWhere(
          (notification) =>
              notification.id == '22222222-2222-4222-8222-222222222222',
        );

        expect(older.title, 'Older notification');
        expect(older.isRead, isFalse);
        expect(older.readAt, isNull);

        expect(older.createdAt, DateTime.utc(2026, 9, 20, 10));

        expect(older.createdAt.isUtc, isTrue);
        expect(older.updatedAt.isUtc, isTrue);

        expect(() => notifications.add(older), throwsUnsupportedError);
      },
    );

    test(
      'preserves nested notification metadata from JsonObject values',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

        addTearDown(() async {
          await server.close(force: true);
        });

        final baseUrl =
            'http://${server.address.address}:${server.port}/api/v1';

        final subscription = server.listen((request) async {
          request.response
            ..statusCode = HttpStatus.ok
            ..headers.contentType = ContentType.json
            ..write(
              jsonEncode(
                _pageEnvelope(
                  baseUrl: baseUrl,
                  page: 1,
                  lastPage: 1,
                  total: 1,
                  notifications: <Map<String, dynamic>>[
                    _notificationJson(
                      id: '33333333-3333-4333-8333-333333333333',
                      title: 'Metadata notification',
                      isRead: false,
                      readAt: null,
                      createdAt: '2026-09-20T11:00:00Z',
                      updatedAt: '2026-09-20T11:00:00Z',
                      data: <String, dynamic>{
                        'text': 'value',
                        'number': 7,
                        'decimal': 2.5,
                        'flag': true,
                        'nothing': null,
                        'object': <String, dynamic>{
                          'key': 'nested-value',
                          'count': 3,
                        },
                        'list': <Object?>[
                          'one',
                          2,
                          true,
                          null,
                          <String, dynamic>{'deep': 'value'},
                        ],
                      },
                    ),
                  ],
                ),
              ),
            );

          await request.response.close();
        });

        addTearDown(subscription.cancel);

        final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

        final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

        final notifications = await dataSource.getNotifications();

        expect(notifications, hasLength(1));

        expect(notifications.single.data, <String, dynamic>{
          'text': 'value',
          'number': 7,
          'decimal': 2.5,
          'flag': true,
          'nothing': null,
          'object': <String, dynamic>{'key': 'nested-value', 'count': 3},
          'list': <Object?>[
            'one',
            2,
            true,
            null,
            <String, dynamic>{'deep': 'value'},
          ],
        });
      },
    );

    test('rejects a notification missing created_at', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      final subscription = server.listen((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode(
              _pageEnvelope(
                baseUrl: baseUrl,
                page: 1,
                lastPage: 1,
                total: 1,
                notifications: <Map<String, dynamic>>[
                  _notificationJson(
                    id: '44444444-4444-4444-8444-444444444444',
                    title: 'Invalid notification',
                    isRead: false,
                    readAt: null,
                    createdAt: null,
                    updatedAt: '2026-09-20T11:00:00Z',
                    data: const <String, dynamic>{},
                  ),
                ],
              ),
            ),
          );

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

      final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

      await expectLater(
        dataSource.getNotifications(),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a notification missing updated_at', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);

      addTearDown(() async {
        await server.close(force: true);
      });

      final baseUrl = 'http://${server.address.address}:${server.port}/api/v1';

      final subscription = server.listen((request) async {
        request.response
          ..statusCode = HttpStatus.ok
          ..headers.contentType = ContentType.json
          ..write(
            jsonEncode(
              _pageEnvelope(
                baseUrl: baseUrl,
                page: 1,
                lastPage: 1,
                total: 1,
                notifications: <Map<String, dynamic>>[
                  _notificationJson(
                    id: '55555555-5555-4555-8555-555555555555',
                    title: 'Invalid notification',
                    isRead: false,
                    readAt: null,
                    createdAt: '2026-09-20T11:00:00Z',
                    updatedAt: null,
                    data: const <String, dynamic>{},
                  ),
                ],
              ),
            ),
          );

        await request.response.close();
      });

      addTearDown(subscription.cancel);

      final apiClient = GeneratedApiClient.create(baseUrl: baseUrl);

      final dataSource = NotificationsRemoteDatasourceImpl(apiClient);

      await expectLater(
        dataSource.getNotifications(),
        throwsA(isA<FormatException>()),
      );
    });
  });
}

Map<String, dynamic> _notificationJson({
  required String id,
  required String title,
  required bool isRead,
  required String? readAt,
  required String? createdAt,
  required String? updatedAt,
  required Map<String, dynamic> data,
}) {
  return <String, dynamic>{
    'id': id,
    'type': 'order_response_received',
    'title': title,
    'body': 'Notification body',
    'data': data,
    'is_read': isRead,
    'read_at': readAt,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };
}

Map<String, dynamic> _pageEnvelope({
  required String baseUrl,
  required int page,
  required int lastPage,
  required int total,
  required List<Map<String, dynamic>> notifications,
}) {
  final previousPage = page > 1 ? page - 1 : null;

  final nextPage = page < lastPage ? page + 1 : null;

  return <String, dynamic>{
    'data': notifications,
    'links': <String, dynamic>{
      'first': '$baseUrl/notifications?page=1',
      'last': '$baseUrl/notifications?page=$lastPage',
      'prev': previousPage == null
          ? null
          : '$baseUrl/notifications?page=$previousPage',
      'next': nextPage == null ? null : '$baseUrl/notifications?page=$nextPage',
    },
    'meta': <String, dynamic>{
      'current_page': page,
      'from': notifications.isEmpty ? null : 1,
      'last_page': lastPage,
      'links': <Map<String, dynamic>>[
        <String, dynamic>{
          'url': previousPage == null
              ? null
              : '$baseUrl/notifications?page=$previousPage',
          'label': 'Previous',
          'active': false,
        },
        <String, dynamic>{
          'url': '$baseUrl/notifications?page=$page',
          'label': '$page',
          'active': true,
        },
        <String, dynamic>{
          'url': nextPage == null
              ? null
              : '$baseUrl/notifications?page=$nextPage',
          'label': 'Next',
          'active': false,
        },
      ],
      'path': '$baseUrl/notifications',
      'per_page': 100,
      'to': notifications.isEmpty ? null : notifications.length,
      'total': total,
    },
  };
}

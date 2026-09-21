import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/data/datasources/local/notifications_local_datasource.dart';
import 'package:talbatiyk/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:talbatiyk/features/notifications/data/models/notifications_model.dart';
import 'package:talbatiyk/features/notifications/data/repositories/notifications_repository_impl.dart';

void main() {
  group('NotificationsRepositoryImpl', () {
    test(
      'refreshes the requested user snapshot from remote then returns the local domain timeline',
      () async {
        final local = _FakeNotificationsLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'stale-a', title: 'Stale notification'),
            ],
            'user-b': <NotificationModel>[
              _notification(
                id: 'user-b-notification',
                title: 'User B notification',
              ),
            ],
          },
        );

        final remote = _FakeNotificationsRemoteDatasource(
          result: <NotificationModel>[
            _notification(
              id: 'fresh-a',
              title: 'Fresh notification',
              data: const <String, dynamic>{'order_id': 'order-1'},
              isRead: true,
              readAt: DateTime.utc(2026, 9, 20, 10),
            ),
          ],
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final notifications = await repository.getNotifications(
          userId: 'user-a',
        );

        expect(remote.calls, 1);

        expect(local.replaceUserIds, <String>['user-a']);

        expect(local.readUserIds, <String>['user-a']);

        expect(notifications, hasLength(1));

        final notification = notifications.single;

        expect(notification.id, 'fresh-a');
        expect(notification.type, 'order_response_received');
        expect(notification.title, 'Fresh notification');
        expect(notification.body, 'Notification body');

        expect(notification.data, const <String, dynamic>{
          'order_id': 'order-1',
        });

        expect(notification.isRead, isTrue);
        expect(notification.readAt, DateTime.utc(2026, 9, 20, 10));
        expect(notification.createdAt, DateTime.utc(2026, 9, 20, 9));
        expect(notification.updatedAt, DateTime.utc(2026, 9, 20, 9, 30));

        // Refreshing A must never delete or overwrite B's cache.
        expect(local.snapshots['user-b']!.single.id, 'user-b-notification');

        expect(() => notifications.add(notification), throwsUnsupportedError);
      },
    );

    test(
      'uses the requested users local snapshot when the network is offline',
      () async {
        final cached = _notification(
          id: 'cached-a',
          title: 'Cached notification',
        );

        final local = _FakeNotificationsLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[cached],
          },
        );

        final remote = _FakeNotificationsRemoteDatasource(
          error: DioException(
            requestOptions: RequestOptions(path: '/notifications'),
            type: DioExceptionType.unknown,
            error: const SocketException('offline'),
          ),
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final notifications = await repository.getNotifications(
          userId: 'user-a',
        );

        expect(notifications.single.id, 'cached-a');
        expect(local.replaceUserIds, isEmpty);
        expect(local.readUserIds, <String>['user-a']);
      },
    );

    for (final statusCode in <int>[408, 429, 500, 503]) {
      test('uses local snapshot for retryable HTTP $statusCode', () async {
        final local = _FakeNotificationsLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(
                id: 'cached-$statusCode',
                title: 'Cached notification',
              ),
            ],
          },
        );

        final requestOptions = RequestOptions(path: '/notifications');

        final remote = _FakeNotificationsRemoteDatasource(
          error: DioException(
            requestOptions: requestOptions,
            response: Response<Object?>(
              requestOptions: requestOptions,
              statusCode: statusCode,
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final notifications = await repository.getNotifications(
          userId: 'user-a',
        );

        expect(notifications.single.id, 'cached-$statusCode');

        expect(local.replaceUserIds, isEmpty);
      });
    }

    for (final statusCode in <int>[401, 403, 404, 422]) {
      test(
        'does not hide definitive HTTP $statusCode behind stale cache',
        () async {
          final local = _FakeNotificationsLocalDatasource(
            snapshots: <String, List<NotificationModel>>{
              'user-a': <NotificationModel>[
                _notification(id: 'stale', title: 'Must not be returned'),
              ],
            },
          );

          final requestOptions = RequestOptions(path: '/notifications');

          final remoteError = DioException(
            requestOptions: requestOptions,
            response: Response<Object?>(
              requestOptions: requestOptions,
              statusCode: statusCode,
            ),
            type: DioExceptionType.badResponse,
          );

          final repository = NotificationsRepositoryImpl(
            localDataSource: local,
            remoteDataSource: _FakeNotificationsRemoteDatasource(
              error: remoteError,
            ),
          );

          await expectLater(
            repository.getNotifications(userId: 'user-a'),
            throwsA(same(remoteError)),
          );

          expect(local.readUserIds, isEmpty);
          expect(local.replaceUserIds, isEmpty);
        },
      );
    }

    test(
      'does not hide malformed remote notification data behind stale cache',
      () async {
        final local = _FakeNotificationsLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'stale', title: 'Must not be returned'),
            ],
          },
        );

        const remoteError = FormatException(
          'Notification response does not contain created_at.',
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeNotificationsRemoteDatasource(
            error: remoteError,
          ),
        );

        await expectLater(
          repository.getNotifications(userId: 'user-a'),
          throwsA(isA<FormatException>()),
        );

        expect(local.readUserIds, isEmpty);
        expect(local.replaceUserIds, isEmpty);
      },
    );
  });
}

NotificationModel _notification({
  required String id,
  required String title,
  Map<String, dynamic> data = const <String, dynamic>{},
  bool isRead = false,
  DateTime? readAt,
}) {
  return NotificationModel(
    id: id,
    type: 'order_response_received',
    title: title,
    body: 'Notification body',
    data: data,
    isRead: isRead,
    readAt: readAt,
    createdAt: DateTime.utc(2026, 9, 20, 9),
    updatedAt: DateTime.utc(2026, 9, 20, 9, 30),
  );
}

final class _FakeNotificationsRemoteDatasource
    implements NotificationsRemoteDatasource {
  _FakeNotificationsRemoteDatasource({
    this.result = const <NotificationModel>[],
    this.error,
  });

  final List<NotificationModel> result;
  final Object? error;

  int calls = 0;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    calls += 1;

    final failure = error;

    if (failure != null) {
      throw failure;
    }

    return result;
  }

  @override
  Future<NotificationModel> markRead({required String notificationId}) {
    throw StateError('Unexpected notification mutation in N3.3 read test.');
  }

  @override
  Future<NotificationMarkAllReadResult> markAllRead() {
    throw StateError('Unexpected mark-all mutation in N3.3 read test.');
  }

  @override
  Future<int> getUnreadCount() {
    throw StateError('Unexpected unread-count request in N3.3 read test.');
  }
}

final class _FakeNotificationsLocalDatasource
    implements NotificationsLocalDatasource {
  _FakeNotificationsLocalDatasource({
    required Map<String, List<NotificationModel>> snapshots,
  }) : snapshots = <String, List<NotificationModel>>{
         for (final entry in snapshots.entries)
           entry.key: List<NotificationModel>.of(entry.value),
       };

  final Map<String, List<NotificationModel>> snapshots;

  final List<String> readUserIds = <String>[];
  final List<String> replaceUserIds = <String>[];

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    readUserIds.add(userId);

    return List<NotificationModel>.unmodifiable(
      snapshots[userId] ?? const <NotificationModel>[],
    );
  }

  @override
  Future<void> replaceNotifications({
    required String userId,
    required List<NotificationModel> notifications,
  }) async {
    replaceUserIds.add(userId);

    snapshots[userId] = List<NotificationModel>.of(notifications);
  }

  @override
  Future<NotificationModel?> markRead({
    required String userId,
    required String notificationId,
    required DateTime readAt,
  }) async {
    return null;
  }

  @override
  Future<int> markAllRead({
    required String userId,
    required DateTime readAt,
  }) async {
    return 0;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    return 0;
  }
}

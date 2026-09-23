import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/data/datasources/local/notifications_local_datasource.dart';
import 'package:talbatiyk/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:talbatiyk/features/notifications/data/models/notifications_model.dart';
import 'package:talbatiyk/features/notifications/data/repositories/notifications_repository_impl.dart';

void main() {
  group('NotificationsRepositoryImpl mutations', () {
    test(
      'markRead is server-first then updates only the requested users local copy',
      () async {
        const notificationId = 'shared-notification';

        final serverReadAt = DateTime.utc(2026, 9, 21, 18, 30);

        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: notificationId, title: 'Cached A'),
            ],
            'user-b': <NotificationModel>[
              _notification(id: notificationId, title: 'Cached B'),
            ],
          },
        );

        final remote = _FakeRemoteDatasource(
          markReadResult: _notification(
            id: notificationId,
            title: 'Server version',
            isRead: true,
            readAt: serverReadAt,
            updatedAt: serverReadAt,
          ),
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: remote,
        );

        final result = await repository.markRead(
          userId: 'user-a',
          notificationId: notificationId,
        );

        expect(result.id, notificationId);
        expect(result.title, 'Server version');
        expect(result.isRead, isTrue);
        expect(result.readAt, serverReadAt);

        expect(local.snapshots['user-a']!.single.isRead, isTrue);

        expect(local.snapshots['user-a']!.single.readAt, serverReadAt);

        expect(local.snapshots['user-b']!.single.isRead, isFalse);

        expect(remote.markReadNotificationIds, <String>[notificationId]);
      },
    );

    test(
      'markRead never mutates local cache when the server mutation fails',
      () async {
        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'notification-a', title: 'Unread'),
            ],
          },
        );

        final requestOptions = RequestOptions(
          path: '/notifications/notification-a/read',
        );

        final remoteError = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeRemoteDatasource(markReadError: remoteError),
        );

        await expectLater(
          repository.markRead(
            userId: 'user-a',
            notificationId: 'notification-a',
          ),
          throwsA(same(remoteError)),
        );

        expect(local.snapshots['user-a']!.single.isRead, isFalse);

        expect(local.markReadCalls, 0);
      },
    );

    test(
      'markAllRead waits for server success then marks only the requested users local cache',
      () async {
        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'a-1', title: 'A1'),
              _notification(id: 'a-2', title: 'A2'),
            ],
            'user-b': <NotificationModel>[
              _notification(id: 'b-1', title: 'B1'),
            ],
          },
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeRemoteDatasource(
            markAllReadResult: (updatedCount: 2, unreadCount: 0),
          ),
        );

        final unreadCount = await repository.markAllRead(userId: 'user-a');

        expect(unreadCount, 0);

        expect(local.snapshots['user-a']!.every((item) => item.isRead), isTrue);

        expect(
          local.snapshots['user-a']!.every(
            (item) => item.readAt?.isUtc ?? false,
          ),
          isTrue,
        );

        expect(local.snapshots['user-b']!.single.isRead, isFalse);
      },
    );

    test(
      'markAllRead never changes local cache when server mutation fails',
      () async {
        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'a-1', title: 'Unread'),
            ],
          },
        );

        final requestOptions = RequestOptions(path: '/notifications/read-all');

        final remoteError = DioException(
          requestOptions: requestOptions,
          type: DioExceptionType.connectionError,
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeRemoteDatasource(
            markAllReadError: remoteError,
          ),
        );

        await expectLater(
          repository.markAllRead(userId: 'user-a'),
          throwsA(same(remoteError)),
        );

        expect(local.snapshots['user-a']!.single.isRead, isFalse);

        expect(local.markAllReadCalls, 0);
      },
    );

    test(
      'getUnreadCount uses the server count when remote is available',
      () async {
        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'local-unread', title: 'Local unread'),
            ],
          },
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeRemoteDatasource(unreadCountResult: 7),
        );

        expect(await repository.getUnreadCount(userId: 'user-a'), 7);

        expect(local.unreadCountCalls, 0);
      },
    );

    test(
      'getUnreadCount falls back to the requested users local count for a retryable transport failure',
      () async {
        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'a-1', title: 'Unread 1'),
              _notification(id: 'a-2', title: 'Unread 2'),
            ],
            'user-b': <NotificationModel>[
              _notification(id: 'b-1', title: 'Unread B'),
            ],
          },
        );

        final remoteError = DioException(
          requestOptions: RequestOptions(path: '/notifications/unread-count'),
          type: DioExceptionType.connectionError,
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeRemoteDatasource(
            unreadCountError: remoteError,
          ),
        );

        expect(await repository.getUnreadCount(userId: 'user-a'), 2);

        expect(local.unreadCountUserIds, <String>['user-a']);
      },
    );

    test(
      'getUnreadCount does not hide a definitive 401 behind local state',
      () async {
        final local = _FakeLocalDatasource(
          snapshots: <String, List<NotificationModel>>{
            'user-a': <NotificationModel>[
              _notification(id: 'stale', title: 'Stale unread'),
            ],
          },
        );

        final requestOptions = RequestOptions(
          path: '/notifications/unread-count',
        );

        final remoteError = DioException(
          requestOptions: requestOptions,
          response: Response<Object?>(
            requestOptions: requestOptions,
            statusCode: 401,
          ),
          type: DioExceptionType.badResponse,
        );

        final repository = NotificationsRepositoryImpl(
          localDataSource: local,
          remoteDataSource: _FakeRemoteDatasource(
            unreadCountError: remoteError,
          ),
        );

        await expectLater(
          repository.getUnreadCount(userId: 'user-a'),
          throwsA(same(remoteError)),
        );

        expect(local.unreadCountCalls, 0);
      },
    );
  });
}

NotificationModel _notification({
  required String id,
  required String title,
  bool isRead = false,
  DateTime? readAt,
  DateTime? updatedAt,
}) {
  return NotificationModel(
    id: id,
    type: 'order_response_received',
    title: title,
    body: 'Notification body',
    data: const <String, dynamic>{'order_id': 'order-1'},
    isRead: isRead,
    readAt: readAt,
    createdAt: DateTime.utc(2026, 9, 21, 18),
    updatedAt: updatedAt ?? DateTime.utc(2026, 9, 21, 18),
  );
}

final class _FakeRemoteDatasource implements NotificationsRemoteDatasource {
  _FakeRemoteDatasource({
    this.markReadResult,
    this.markReadError,
    this.markAllReadResult = const (updatedCount: 0, unreadCount: 0),
    this.markAllReadError,
    this.unreadCountResult = 0,
    this.unreadCountError,
  });

  final NotificationModel? markReadResult;
  final Object? markReadError;

  final ({int updatedCount, int unreadCount}) markAllReadResult;

  final Object? markAllReadError;

  final int unreadCountResult;
  final Object? unreadCountError;

  final List<String> markReadNotificationIds = <String>[];

  @override
  Future<List<NotificationModel>> getNotifications() async {
    return const <NotificationModel>[];
  }

  @override
  Future<NotificationModel> markRead({required String notificationId}) async {
    markReadNotificationIds.add(notificationId);

    final failure = markReadError;

    if (failure != null) {
      throw failure;
    }

    return markReadResult!;
  }

  @override
  Future<({int updatedCount, int unreadCount})> markAllRead() async {
    final failure = markAllReadError;

    if (failure != null) {
      throw failure;
    }

    return markAllReadResult;
  }

  @override
  Future<int> getUnreadCount() async {
    final failure = unreadCountError;

    if (failure != null) {
      throw failure;
    }

    return unreadCountResult;
  }
}

final class _FakeLocalDatasource implements NotificationsLocalDatasource {
  _FakeLocalDatasource({
    required Map<String, List<NotificationModel>> snapshots,
  }) : snapshots = <String, List<NotificationModel>>{
         for (final entry in snapshots.entries)
           entry.key: List<NotificationModel>.of(entry.value),
       };

  final Map<String, List<NotificationModel>> snapshots;

  int markReadCalls = 0;
  int markAllReadCalls = 0;
  int unreadCountCalls = 0;

  final List<String> unreadCountUserIds = <String>[];

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    return List<NotificationModel>.unmodifiable(
      snapshots[userId] ?? const <NotificationModel>[],
    );
  }

  @override
  Future<void> replaceNotifications({
    required String userId,
    required List<NotificationModel> notifications,
  }) async {
    snapshots[userId] = List<NotificationModel>.of(notifications);
  }

  @override
  Future<NotificationModel?> markRead({
    required String userId,
    required String notificationId,
    required DateTime readAt,
  }) async {
    markReadCalls += 1;

    final items = snapshots[userId];

    if (items == null) {
      return null;
    }

    final index = items.indexWhere((item) => item.id == notificationId);

    if (index < 0) {
      return null;
    }

    final current = items[index];

    final updated = NotificationModel(
      id: current.id,
      type: current.type,
      title: current.title,
      body: current.body,
      data: current.data,
      isRead: true,
      readAt: readAt.toUtc(),
      createdAt: current.createdAt,
      updatedAt: current.updatedAt,
    );

    items[index] = updated;

    return updated;
  }

  @override
  Future<int> markAllRead({
    required String userId,
    required DateTime readAt,
  }) async {
    markAllReadCalls += 1;

    final items = snapshots[userId];

    if (items == null) {
      return 0;
    }

    var updatedCount = 0;

    for (var index = 0; index < items.length; index += 1) {
      final current = items[index];

      if (current.isRead) {
        continue;
      }

      items[index] = NotificationModel(
        id: current.id,
        type: current.type,
        title: current.title,
        body: current.body,
        data: current.data,
        isRead: true,
        readAt: readAt.toUtc(),
        createdAt: current.createdAt,
        updatedAt: current.updatedAt,
      );

      updatedCount += 1;
    }

    return updatedCount;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    unreadCountCalls += 1;
    unreadCountUserIds.add(userId);

    return snapshots[userId]?.where((item) => !item.isRead).length ?? 0;
  }
}

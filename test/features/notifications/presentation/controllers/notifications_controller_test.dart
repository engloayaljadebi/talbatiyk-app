import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';
import 'package:talbatiyk/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:talbatiyk/features/notifications/presentation/state/notifications_state.dart';

void main() {
  group('NotificationsController', () {
    late _FakeNotificationsRepository repository;
    late NotificationsController controller;

    setUp(() {
      repository = _FakeNotificationsRepository();

      controller = NotificationsController(
        NotificationsUseCase(repository),
        userId: 'user-a',
        autoLoad: false,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test(
      'starts isolated to the explicit user with an empty initial state',
      () {
        expect(controller.userId, 'user-a');

        expect(controller.state.status, NotificationsLoadStatus.initial);

        expect(controller.state.notifications, isEmpty);
        expect(controller.state.unreadCount, 0);
        expect(controller.state.errorMessage, isNull);
        expect(controller.state.markingReadNotificationId, isNull);
        expect(controller.state.isMarkingAllRead, isFalse);
      },
    );

    test(
      'load forwards userId and exposes notifications with unread count',
      () async {
        repository.notificationsByUser['user-a'] = <NotificationsEntity>[
          _notification(id: 'n-1', title: 'Unread'),
          _notification(
            id: 'n-2',
            title: 'Read',
            isRead: true,
            readAt: DateTime.utc(2026, 9, 21, 19),
          ),
        ];

        repository.unreadCountByUser['user-a'] = 1;

        final future = controller.load();

        expect(controller.state.status, NotificationsLoadStatus.loading);

        await future;

        expect(controller.state.status, NotificationsLoadStatus.loaded);

        expect(
          controller.state.notifications.map((item) => item.id).toList(),
          <String>['n-1', 'n-2'],
        );

        expect(controller.state.unreadCount, 1);

        expect(repository.listUserIds, <String>['user-a']);

        expect(repository.unreadCountUserIds, <String>['user-a']);
      },
    );

    test('load clears stale presentation data on definitive failure', () async {
      repository.notificationsByUser['user-a'] = <NotificationsEntity>[
        _notification(id: 'n-1', title: 'Old notification'),
      ];

      repository.unreadCountByUser['user-a'] = 1;

      await controller.load();

      expect(controller.state.notifications, hasLength(1));

      repository.listError = StateError('definitive failure');

      await controller.load();

      expect(controller.state.status, NotificationsLoadStatus.failure);

      expect(controller.state.notifications, isEmpty);
      expect(controller.state.unreadCount, 0);
      expect(controller.state.errorMessage, isNotEmpty);
    });

    test(
      'markRead forwards explicit userId and refreshes authoritative unread count',
      () async {
        repository.notificationsByUser['user-a'] = <NotificationsEntity>[
          _notification(id: 'n-1', title: 'Unread'),
        ];

        repository.unreadCountByUser['user-a'] = 1;

        await controller.load();

        repository.markReadResult = _notification(
          id: 'n-1',
          title: 'Unread',
          isRead: true,
          readAt: DateTime.utc(2026, 9, 21, 20),
        );

        repository.unreadCountByUser['user-a'] = 0;

        final result = await controller.markRead('n-1');

        expect(result, isTrue);

        expect(repository.markReadRequests, <(String, String)>[
          ('user-a', 'n-1'),
        ]);

        expect(controller.state.notifications.single.isRead, isTrue);

        expect(
          controller.state.notifications.single.readAt,
          DateTime.utc(2026, 9, 21, 20),
        );

        expect(controller.state.unreadCount, 0);

        expect(controller.state.markingReadNotificationId, isNull);
      },
    );

    test(
      'markRead failure preserves the current snapshot and unread count',
      () async {
        repository.notificationsByUser['user-a'] = <NotificationsEntity>[
          _notification(id: 'n-1', title: 'Unread'),
        ];

        repository.unreadCountByUser['user-a'] = 1;

        await controller.load();

        repository.markReadError = StateError('mutation failed');

        final result = await controller.markRead('n-1');

        expect(result, isFalse);

        expect(controller.state.notifications.single.isRead, isFalse);

        expect(controller.state.unreadCount, 1);
        expect(controller.state.errorMessage, isNotEmpty);

        expect(controller.state.markingReadNotificationId, isNull);
      },
    );

    test(
      'markAllRead forwards userId and refreshes the list after server success',
      () async {
        repository.notificationsByUser['user-a'] = <NotificationsEntity>[
          _notification(id: 'n-1', title: 'First'),
          _notification(id: 'n-2', title: 'Second'),
        ];

        repository.unreadCountByUser['user-a'] = 2;

        await controller.load();

        repository.onMarkAllRead = (userId) {
          repository.notificationsByUser[userId] = repository
              .notificationsByUser[userId]!
              .map(
                (item) => _notification(
                  id: item.id,
                  title: item.title,
                  isRead: true,
                  readAt: DateTime.utc(2026, 9, 21, 21),
                ),
              )
              .toList();

          repository.unreadCountByUser[userId] = 0;
        };

        final result = await controller.markAllRead();

        expect(result, isTrue);

        expect(repository.markAllReadUserIds, <String>['user-a']);

        expect(
          controller.state.notifications.every((item) => item.isRead),
          isTrue,
        );

        expect(controller.state.unreadCount, 0);
        expect(controller.state.isMarkingAllRead, isFalse);
      },
    );

    test('markAllRead failure preserves the current snapshot', () async {
      repository.notificationsByUser['user-a'] = <NotificationsEntity>[
        _notification(id: 'n-1', title: 'Unread'),
      ];

      repository.unreadCountByUser['user-a'] = 1;

      await controller.load();

      repository.markAllReadError = StateError('mark all failed');

      final result = await controller.markAllRead();

      expect(result, isFalse);

      expect(controller.state.notifications.single.isRead, isFalse);

      expect(controller.state.unreadCount, 1);
      expect(controller.state.errorMessage, isNotEmpty);
      expect(controller.state.isMarkingAllRead, isFalse);
    });
  });
}

NotificationsEntity _notification({
  required String id,
  required String title,
  bool isRead = false,
  DateTime? readAt,
}) {
  return NotificationsEntity(
    id: id,
    type: 'order_response_received',
    title: title,
    body: 'Notification body',
    data: const <String, dynamic>{'order_id': 'order-1'},
    isRead: isRead,
    readAt: readAt,
    createdAt: DateTime.utc(2026, 9, 21, 18),
    updatedAt: readAt ?? DateTime.utc(2026, 9, 21, 18),
  );
}

final class _FakeNotificationsRepository implements NotificationsRepository {
  final Map<String, List<NotificationsEntity>> notificationsByUser =
      <String, List<NotificationsEntity>>{};

  final Map<String, int> unreadCountByUser = <String, int>{};

  final List<String> listUserIds = <String>[];

  final List<String> unreadCountUserIds = <String>[];

  final List<(String, String)> markReadRequests = <(String, String)>[];

  final List<String> markAllReadUserIds = <String>[];

  Object? listError;
  Object? unreadCountError;
  Object? markReadError;
  Object? markAllReadError;

  NotificationsEntity? markReadResult;

  void Function(String userId)? onMarkAllRead;

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    listUserIds.add(userId);

    final failure = listError;

    if (failure != null) {
      throw failure;
    }

    return List<NotificationsEntity>.unmodifiable(
      notificationsByUser[userId] ?? const <NotificationsEntity>[],
    );
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) async {
    markReadRequests.add((userId, notificationId));

    final failure = markReadError;

    if (failure != null) {
      throw failure;
    }

    final result = markReadResult;

    if (result == null) {
      throw StateError('markReadResult was not configured.');
    }

    final items = notificationsByUser[userId] ?? const <NotificationsEntity>[];

    notificationsByUser[userId] = <NotificationsEntity>[
      for (final item in items)
        if (item.id == result.id) result else item,
    ];

    return result;
  }

  @override
  Future<int> markAllRead({required String userId}) async {
    markAllReadUserIds.add(userId);

    final failure = markAllReadError;

    if (failure != null) {
      throw failure;
    }

    onMarkAllRead?.call(userId);

    return unreadCountByUser[userId] ?? 0;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    unreadCountUserIds.add(userId);

    final failure = unreadCountError;

    if (failure != null) {
      throw failure;
    }

    return unreadCountByUser[userId] ?? 0;
  }
}

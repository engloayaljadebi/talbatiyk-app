import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';
import 'package:talbatiyk/features/notifications/presentation/controllers/notifications_controller.dart';

void main() {
  group('NotificationsController committed mutation resilience', () {
    test(
      'markRead keeps committed state when unread refresh fails after mutation',
      () async {
        final repository = _CommittedMutationRepository(
          notifications: <NotificationsEntity>[_notification(id: 'n-1')],
          unreadCount: 1,
        );

        final controller = NotificationsController(
          NotificationsUseCase(repository),
          userId: 'user-a',
          autoLoad: false,
        );

        addTearDown(controller.dispose);

        await controller.load();

        repository.failUnreadCount = true;

        final succeeded = await controller.markRead('n-1');

        expect(
          succeeded,
          isTrue,
          reason:
              'Primary server mutation succeeded; a secondary unread refresh '
              'must not turn the operation into a failed mutation.',
        );

        expect(controller.state.notifications.single.isRead, isTrue);

        expect(controller.state.notifications.single.readAt, isNotNull);

        expect(controller.state.unreadCount, 0);

        expect(
          controller.state.errorMessage,
          isNotEmpty,
          reason:
              'Secondary refresh failure may be surfaced as a warning '
              'without rolling back committed state.',
        );

        expect(controller.state.markingReadNotificationId, isNull);
      },
    );

    test(
      'markAllRead keeps committed state when list refresh fails after mutation',
      () async {
        final repository = _CommittedMutationRepository(
          notifications: <NotificationsEntity>[
            _notification(id: 'n-1'),
            _notification(id: 'n-2'),
          ],
          unreadCount: 2,
        );

        final controller = NotificationsController(
          NotificationsUseCase(repository),
          userId: 'user-a',
          autoLoad: false,
        );

        addTearDown(controller.dispose);

        await controller.load();

        repository.failList = true;

        final succeeded = await controller.markAllRead();

        expect(
          succeeded,
          isTrue,
          reason:
              'mark-all already committed remotely and locally before '
              'the secondary timeline refresh failed.',
        );

        expect(
          controller.state.notifications.every(
            (notification) => notification.isRead,
          ),
          isTrue,
        );

        expect(
          controller.state.notifications.every(
            (notification) => notification.readAt != null,
          ),
          isTrue,
        );

        expect(controller.state.unreadCount, 0);

        expect(controller.state.errorMessage, isNotEmpty);

        expect(controller.state.isMarkingAllRead, isFalse);
      },
    );
  });
}

NotificationsEntity _notification({
  required String id,
  bool isRead = false,
  DateTime? readAt,
}) {
  return NotificationsEntity(
    id: id,
    type: 'order_response_received',
    title: 'Notification $id',
    body: 'Body',
    data: const <String, dynamic>{'order_id': 'order-1'},
    isRead: isRead,
    readAt: readAt,
    createdAt: DateTime.utc(2026, 9, 21, 18),
    updatedAt: readAt ?? DateTime.utc(2026, 9, 21, 18),
  );
}

NotificationsEntity _copyRead(
  NotificationsEntity notification,
  DateTime readAt,
) {
  return NotificationsEntity(
    id: notification.id,
    type: notification.type,
    title: notification.title,
    body: notification.body,
    data: notification.data,
    isRead: true,
    readAt: readAt,
    createdAt: notification.createdAt,
    updatedAt: readAt,
  );
}

final class _CommittedMutationRepository implements NotificationsRepository {
  _CommittedMutationRepository({
    required List<NotificationsEntity> notifications,
    required this.unreadCount,
  }) : notifications = List<NotificationsEntity>.of(notifications);

  List<NotificationsEntity> notifications;

  int unreadCount;

  bool failList = false;
  bool failUnreadCount = false;

  final DateTime mutationTime = DateTime.utc(2026, 9, 21, 22);

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    if (failList) {
      throw StateError('Timeline refresh failed after committed mutation.');
    }

    return List<NotificationsEntity>.unmodifiable(notifications);
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) async {
    final index = notifications.indexWhere(
      (notification) => notification.id == notificationId,
    );

    if (index < 0) {
      throw StateError('Notification not found.');
    }

    final before = notifications[index];

    final updated = _copyRead(before, mutationTime);

    notifications[index] = updated;

    if (!before.isRead && unreadCount > 0) {
      unreadCount -= 1;
    }

    return updated;
  }

  @override
  Future<int> markAllRead({required String userId}) async {
    notifications = <NotificationsEntity>[
      for (final notification in notifications)
        _copyRead(notification, mutationTime),
    ];

    unreadCount = 0;

    return 0;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    if (failUnreadCount) {
      throw StateError('Unread refresh failed after committed mutation.');
    }

    return unreadCount;
  }
}

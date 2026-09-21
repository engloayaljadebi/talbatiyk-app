import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';

void main() {
  group('NotificationsUseCase mutations', () {
    test('markRead forwards explicit user and notification ids', () async {
      final repository = _RecordingNotificationsRepository();

      final useCase = NotificationsUseCase(repository);

      final result = await useCase.markRead(
        userId: 'user-a',
        notificationId: 'notification-a',
      );

      expect(result.id, 'notification-a');

      expect(repository.markReadRequests, <(String, String)>[
        ('user-a', 'notification-a'),
      ]);
    });

    test('markAllRead forwards the explicit user id', () async {
      final repository = _RecordingNotificationsRepository();

      final useCase = NotificationsUseCase(repository);

      expect(await useCase.markAllRead(userId: 'user-a'), 0);

      expect(repository.markAllReadUserIds, <String>['user-a']);
    });

    test('getUnreadCount forwards the explicit user id', () async {
      final repository = _RecordingNotificationsRepository(unreadCount: 3);

      final useCase = NotificationsUseCase(repository);

      expect(await useCase.getUnreadCount(userId: 'user-a'), 3);

      expect(repository.unreadCountUserIds, <String>['user-a']);
    });
  });
}

final class _RecordingNotificationsRepository
    implements NotificationsRepository {
  _RecordingNotificationsRepository({this.unreadCount = 0});

  final int unreadCount;

  final List<(String, String)> markReadRequests = <(String, String)>[];

  final List<String> markAllReadUserIds = <String>[];

  final List<String> unreadCountUserIds = <String>[];

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    return const <NotificationsEntity>[];
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) async {
    markReadRequests.add((userId, notificationId));

    return NotificationsEntity(
      id: notificationId,
      type: 'order_response_received',
      title: 'Read',
      body: 'Body',
      data: const <String, dynamic>{},
      isRead: true,
      readAt: DateTime.utc(2026, 9, 21, 18),
      createdAt: DateTime.utc(2026, 9, 21, 17),
      updatedAt: DateTime.utc(2026, 9, 21, 18),
    );
  }

  @override
  Future<int> markAllRead({required String userId}) async {
    markAllReadUserIds.add(userId);

    return 0;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    unreadCountUserIds.add(userId);

    return unreadCount;
  }
}

import '../entities/notifications_entity.dart';

abstract class NotificationsRepository {
  Future<List<NotificationsEntity>> getNotifications({required String userId});

  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  });

  Future<int> markAllRead({required String userId});

  Future<int> getUnreadCount({required String userId});
}

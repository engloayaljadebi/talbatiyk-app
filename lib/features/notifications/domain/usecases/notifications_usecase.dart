import '../entities/notifications_entity.dart';
import '../repositories/notifications_repository.dart';

class NotificationsUseCase {
  final NotificationsRepository repository;

  NotificationsUseCase(this.repository);

  Future<List<NotificationsEntity>> call({required String userId}) {
    return repository.getNotifications(userId: userId);
  }

  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) {
    return repository.markRead(userId: userId, notificationId: notificationId);
  }

  Future<int> markAllRead({required String userId}) {
    return repository.markAllRead(userId: userId);
  }

  Future<int> getUnreadCount({required String userId}) {
    return repository.getUnreadCount(userId: userId);
  }
}

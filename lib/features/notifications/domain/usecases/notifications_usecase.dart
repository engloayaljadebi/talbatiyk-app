import '../entities/notifications_entity.dart';
import '../repositories/notifications_repository.dart';

class NotificationsUseCase {
  final NotificationsRepository repository;

  NotificationsUseCase(this.repository);

  Future<List<NotificationsEntity>> call() {
    return repository.getNotifications();
  }
}

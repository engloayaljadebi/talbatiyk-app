import '../../domain/entities/notifications_entity.dart';
import '../../domain/repositories/notifications_repository.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  @override
  Future<List<NotificationsEntity>> getNotifications() async {
    return [];
  }
}

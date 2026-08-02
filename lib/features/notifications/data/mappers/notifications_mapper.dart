import '../../domain/entities/notifications_entity.dart';
import '../models/notifications_model.dart';

class NotificationsMapper {
  static NotificationsEntity toEntity(NotificationsModel model) {
    return NotificationsEntity(id: model.id);
  }
}

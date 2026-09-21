import '../../../../../core/network/generated_api_client.dart';
import '../../mappers/notifications_mapper.dart';
import '../../models/notifications_model.dart';

typedef NotificationMarkAllReadResult = ({int updatedCount, int unreadCount});

abstract class NotificationsRemoteDatasource {
  Future<List<NotificationModel>> getNotifications();

  Future<NotificationModel> markRead({required String notificationId});

  Future<NotificationMarkAllReadResult> markAllRead();

  Future<int> getUnreadCount();
}

class NotificationsRemoteDatasourceImpl
    implements NotificationsRemoteDatasource {
  NotificationsRemoteDatasourceImpl(this._apiClient);

  static const int _perPage = 100;

  final GeneratedApiClient _apiClient;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final notificationsById = <String, NotificationModel>{};

    var page = 1;

    while (true) {
      final response = await _apiClient.notifications.notificationIndex(
        page: page,
        perPage: _perPage,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw StateError('Notifications response does not contain data.');
      }

      for (final resource in responseBody.data) {
        final notification = NotificationsMapper.fromResource(resource);

        notificationsById[notification.id] = notification;
      }

      if (page >= responseBody.meta.lastPage) {
        break;
      }

      page += 1;
    }

    return List<NotificationModel>.unmodifiable(notificationsById.values);
  }

  @override
  Future<NotificationModel> markRead({required String notificationId}) async {
    final response = await _apiClient.notifications.notificationMarkRead(
      notification: notificationId,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Mark-read response does not contain data.');
    }

    final notification = NotificationsMapper.fromResource(responseBody.data);

    if (notification.id != notificationId) {
      throw const FormatException(
        'Mark-read response notification id does not match the request.',
      );
    }

    if (!notification.isRead || notification.readAt == null) {
      throw const FormatException(
        'Mark-read response does not contain a valid read state.',
      );
    }

    return notification;
  }

  @override
  Future<NotificationMarkAllReadResult> markAllRead() async {
    final response = await _apiClient.notifications.notificationMarkAllRead();

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Mark-all-read response does not contain data.');
    }

    return (
      updatedCount: responseBody.data.updatedCount,
      unreadCount: responseBody.data.unreadCount,
    );
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.notifications.notificationUnreadCount();

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('Unread-count response does not contain data.');
    }

    return responseBody.data.unreadCount;
  }
}

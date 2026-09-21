import '../../domain/entities/notifications_entity.dart';

enum NotificationsLoadStatus { initial, loading, loaded, failure }

final class NotificationsState {
  const NotificationsState({
    this.status = NotificationsLoadStatus.initial,
    this.notifications = const <NotificationsEntity>[],
    this.unreadCount = 0,
    this.markingReadNotificationId,
    this.isMarkingAllRead = false,
    this.errorMessage,
  });

  final NotificationsLoadStatus status;

  final List<NotificationsEntity> notifications;

  final int unreadCount;

  final String? markingReadNotificationId;

  final bool isMarkingAllRead;

  final String? errorMessage;

  bool get isLoading => status == NotificationsLoadStatus.loading;

  bool get hasFailure => status == NotificationsLoadStatus.failure;

  bool get hasNotifications => notifications.isNotEmpty;

  bool get hasUnread => unreadCount > 0;

  bool get isMutating => markingReadNotificationId != null || isMarkingAllRead;

  NotificationsState copyWith({
    NotificationsLoadStatus? status,
    List<NotificationsEntity>? notifications,
    int? unreadCount,
    String? markingReadNotificationId,
    bool clearMarkingReadNotificationId = false,
    bool? isMarkingAllRead,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications == null
          ? this.notifications
          : List<NotificationsEntity>.unmodifiable(notifications),
      unreadCount: unreadCount ?? this.unreadCount,
      markingReadNotificationId: clearMarkingReadNotificationId
          ? null
          : markingReadNotificationId ?? this.markingReadNotificationId,
      isMarkingAllRead: isMarkingAllRead ?? this.isMarkingAllRead,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

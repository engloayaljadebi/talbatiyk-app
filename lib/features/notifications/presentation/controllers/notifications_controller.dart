import 'package:flutter/foundation.dart';

import '../../domain/entities/notifications_entity.dart';
import '../../domain/usecases/notifications_usecase.dart';
import '../state/notifications_state.dart';

final class NotificationsController extends ChangeNotifier {
  NotificationsController(
    this._useCase, {
    required this.userId,
    bool autoLoad = false,
  }) {
    if (autoLoad) {
      load();
    }
  }

  final NotificationsUseCase _useCase;

  final String userId;

  NotificationsState state = const NotificationsState();

  bool _disposed = false;

  Future<void> load() async {
    if (state.isLoading || _disposed) {
      return;
    }

    _setState(
      state.copyWith(
        status: NotificationsLoadStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final notifications = await _useCase(userId: userId);

      final unreadCount = await _useCase.getUnreadCount(userId: userId);

      if (_disposed) {
        return;
      }

      _setState(
        NotificationsState(
          status: NotificationsLoadStatus.loaded,
          notifications: List<NotificationsEntity>.unmodifiable(notifications),
          unreadCount: unreadCount,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Notifications loading failed: '
        '$error\n$stackTrace',
      );

      if (_disposed) {
        return;
      }

      _setState(
        const NotificationsState(
          status: NotificationsLoadStatus.failure,
          errorMessage: 'تعذر تحميل الإشعارات. حاول مرة أخرى.',
        ),
      );
    }
  }

  Future<bool> markRead(String notificationId) async {
    if (_disposed ||
        notificationId.trim().isEmpty ||
        state.isMarkingAllRead ||
        state.markingReadNotificationId != null) {
      return false;
    }

    final snapshot = state;

    _setState(
      state.copyWith(
        markingReadNotificationId: notificationId,
        clearErrorMessage: true,
      ),
    );

    late final NotificationsEntity updated;

    try {
      updated = await _useCase.markRead(
        userId: userId,
        notificationId: notificationId,
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Notification mark-read mutation failed: '
        '$error\n$stackTrace',
      );

      if (_disposed) {
        return false;
      }

      _setState(
        snapshot.copyWith(
          errorMessage: 'تعذر تحديث حالة الإشعار. حاول مرة أخرى.',
          clearMarkingReadNotificationId: true,
        ),
      );

      return false;
    }

    final wasUnread = snapshot.notifications.any(
      (notification) => notification.id == updated.id && !notification.isRead,
    );

    final committedUnreadCount = wasUnread && snapshot.unreadCount > 0
        ? snapshot.unreadCount - 1
        : snapshot.unreadCount;

    final committedNotifications = <NotificationsEntity>[
      for (final notification in snapshot.notifications)
        if (notification.id == updated.id) updated else notification,
    ];

    var unreadCount = committedUnreadCount;

    String? refreshWarning;

    try {
      unreadCount = await _useCase.getUnreadCount(userId: userId);
    } catch (error, stackTrace) {
      debugPrint(
        'Notification unread-count refresh failed '
        'after committed mark-read: '
        '$error\n$stackTrace',
      );

      refreshWarning = 'تم تحديث الإشعار، لكن تعذر تحديث العدد الآن.';
    }

    if (_disposed) {
      return true;
    }

    _setState(
      state.copyWith(
        status: NotificationsLoadStatus.loaded,
        notifications: committedNotifications,
        unreadCount: unreadCount,
        clearMarkingReadNotificationId: true,
        errorMessage: refreshWarning,
        clearErrorMessage: refreshWarning == null,
      ),
    );

    return true;
  }

  Future<bool> markAllRead() async {
    if (_disposed ||
        state.isMarkingAllRead ||
        state.markingReadNotificationId != null) {
      return false;
    }

    final snapshot = state;

    _setState(state.copyWith(isMarkingAllRead: true, clearErrorMessage: true));

    late final int unreadCount;

    try {
      unreadCount = await _useCase.markAllRead(userId: userId);
    } catch (error, stackTrace) {
      debugPrint(
        'Notifications mark-all-read mutation failed: '
        '$error\n$stackTrace',
      );

      if (_disposed) {
        return false;
      }

      _setState(
        snapshot.copyWith(
          isMarkingAllRead: false,
          errorMessage: 'تعذر تعليم جميع الإشعارات كمقروءة.',
        ),
      );

      return false;
    }

    final committedReadAt = DateTime.now().toUtc();

    final committedNotifications = <NotificationsEntity>[
      for (final notification in snapshot.notifications)
        _asRead(notification, committedReadAt),
    ];

    var notifications = committedNotifications;

    String? refreshWarning;

    try {
      notifications = await _useCase(userId: userId);
    } catch (error, stackTrace) {
      debugPrint(
        'Notifications timeline refresh failed '
        'after committed mark-all-read: '
        '$error\n$stackTrace',
      );

      refreshWarning =
          'تم تعليم الإشعارات كمقروءة، لكن تعذر تحديث القائمة الآن.';
    }

    if (_disposed) {
      return true;
    }

    _setState(
      NotificationsState(
        status: NotificationsLoadStatus.loaded,
        notifications: List<NotificationsEntity>.unmodifiable(notifications),
        unreadCount: unreadCount,
        errorMessage: refreshWarning,
      ),
    );

    return true;
  }

  NotificationsEntity _asRead(
    NotificationsEntity notification,
    DateTime readAt,
  ) {
    if (notification.isRead) {
      return notification;
    }

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

  void _setState(NotificationsState value) {
    if (_disposed) {
      return;
    }

    state = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

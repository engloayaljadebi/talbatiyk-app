import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/notifications_entity.dart';
import '../state/notifications_state.dart';

class NotificationsWidget extends StatelessWidget {
  const NotificationsWidget({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onRefresh,
    required this.onMarkRead,
  });

  final NotificationsState state;

  final Future<void> Function() onRetry;

  final Future<void> Function() onRefresh;

  final Future<bool> Function(String notificationId) onMarkRead;

  @override
  Widget build(BuildContext context) {
    if ((state.status == NotificationsLoadStatus.initial ||
            state.status == NotificationsLoadStatus.loading) &&
        state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasFailure && state.notifications.isEmpty) {
      return _FailureState(message: state.errorMessage, onRetry: onRetry);
    }

    if (state.notifications.isEmpty) {
      return _EmptyState(onRefresh: onRefresh);
    }

    return Column(
      children: [
        if (state.errorMessage != null)
          _InlineError(message: state.errorMessage!),
        Expanded(
          child: RefreshIndicator(
            onRefresh: onRefresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
              itemCount: state.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification = state.notifications[index];

                return _NotificationTile(
                  notification: notification,
                  isMutating:
                      state.markingReadNotificationId == notification.id,
                  mutationsLocked: state.isMarkingAllRead,
                  onMarkRead: onMarkRead,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

final class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isMutating,
    required this.mutationsLocked,
    required this.onMarkRead,
  });

  final NotificationsEntity notification;

  final bool isMutating;

  final bool mutationsLocked;

  final Future<bool> Function(String notificationId) onMarkRead;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return Material(
      color: isUnread ? AppColors.primaryLight : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        key: ValueKey<String>('notification-tile-${notification.id}'),
        borderRadius: BorderRadius.circular(16),
        onTap: !isUnread || isMutating || mutationsLocked
            ? null
            : () async {
                await onMarkRead(notification.id);
              },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? AppColors.primary.withValues(alpha: 0.20)
                  : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isUnread
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnread
                      ? Icons.notifications_active_outlined
                      : Icons.notifications_none_outlined,
                  color: isUnread ? AppColors.primary : Colors.black54,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15,
                              height: 1.35,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            key: ValueKey<String>(
                              'notification-unread-${notification.id}',
                            ),
                            width: 9,
                            height: 9,
                            margin: const EdgeInsets.only(top: 5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      notification.body,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDate(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const Spacer(),
                        if (isMutating)
                          const SizedBox(
                            width: 17,
                            height: 17,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();

    String twoDigits(int number) {
      return number.toString().padLeft(2, '0');
    }

    return '${twoDigits(local.day)}/'
        '${twoDigits(local.month)}/'
        '${local.year} '
        '• '
        '${twoDigits(local.hour)}:'
        '${twoDigits(local.minute)}';
  }
}

final class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 80),
        children: const [
          Icon(
            Icons.notifications_none_rounded,
            size: 64,
            color: Colors.black26,
          ),
          SizedBox(height: 18),
          Text(
            'لا توجد إشعارات',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'ستظهر هنا تنبيهات الطلبات والتحديثات المهمة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

final class _FailureState extends StatelessWidget {
  const _FailureState({required this.message, required this.onRetry});

  final String? message;

  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? 'تعذر تحميل الإشعارات.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: () async {
                await onRetry();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

final class _InlineError extends StatelessWidget {
  const _InlineError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12.5, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../providers/notifications_provider.dart';
import '../widgets/notifications_widget.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key, required this.userId});

  final String userId;

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

final class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      unawaited(ref.read(notificationsProvider(widget.userId)).load());
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(notificationsProvider(widget.userId));

    final state = controller.state;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: AppColors.surface,
          surfaceTintColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          title: const Text(
            'الإشعارات',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          actions: [
            if (state.hasUnread)
              TextButton(
                key: const ValueKey<String>('notifications-mark-all-read'),
                onPressed: state.isMutating
                    ? null
                    : () async {
                        await controller.markAllRead();
                      },
                child: const Text(
                  'تحديد الكل كمقروء',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: NotificationsWidget(
            state: state,
            onRetry: controller.load,
            onRefresh: controller.load,
            onMarkRead: controller.markRead,
          ),
        ),
      ),
    );
  }
}

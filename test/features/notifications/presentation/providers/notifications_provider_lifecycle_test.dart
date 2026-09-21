import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';
import 'package:talbatiyk/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  test(
    'per-user notification controller is disposed after its final listener closes',
    () async {
      final container = ProviderContainer(
        overrides: [
          notificationsUseCaseProvider.overrideWithValue(
            NotificationsUseCase(_NeverCalledNotificationsRepository()),
          ),
        ],
      );

      addTearDown(container.dispose);

      final firstSubscription = container.listen(
        notificationsProvider('user-a'),
        (_, _) {},
        fireImmediately: true,
      );

      final firstController = container.read(notificationsProvider('user-a'));

      firstSubscription.close();

      await container.pump();

      final secondSubscription = container.listen(
        notificationsProvider('user-a'),
        (_, _) {},
        fireImmediately: true,
      );

      addTearDown(secondSubscription.close);

      final secondController = container.read(notificationsProvider('user-a'));

      expect(
        identical(firstController, secondController),
        isFalse,
        reason:
            'Sensitive per-user notification state should not remain '
            'cached after the last consumer leaves.',
      );
    },
  );
}

final class _NeverCalledNotificationsRepository
    implements NotificationsRepository {
  @override
  Future<List<NotificationsEntity>> getNotifications({required String userId}) {
    throw StateError('Unexpected notification read.');
  }

  @override
  Future<int> getUnreadCount({required String userId}) {
    throw StateError('Unexpected unread-count read.');
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) {
    throw StateError('Unexpected notification mutation.');
  }

  @override
  Future<int> markAllRead({required String userId}) {
    throw StateError('Unexpected mark-all mutation.');
  }
}

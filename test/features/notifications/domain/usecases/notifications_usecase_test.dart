import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';

void main() {
  test(
    'NotificationsUseCase forwards the explicit user id to the repository',
    () async {
      final repository = _RecordingNotificationsRepository();

      final useCase = NotificationsUseCase(repository);

      await useCase(userId: 'user-a');

      expect(repository.requestedUserIds, <String>['user-a']);
    },
  );
}

final class _RecordingNotificationsRepository
    implements NotificationsRepository {
  final List<String> requestedUserIds = <String>[];

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    requestedUserIds.add(userId);

    return const <NotificationsEntity>[];
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) {
    throw StateError('Unexpected notification mutation in N3.3 use-case test.');
  }

  @override
  Future<int> markAllRead({required String userId}) {
    throw StateError('Unexpected mark-all mutation in N3.3 use-case test.');
  }

  @override
  Future<int> getUnreadCount({required String userId}) {
    throw StateError('Unexpected unread-count request in N3.3 use-case test.');
  }
}

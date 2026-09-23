import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/core/network/network_providers.dart';
import 'package:talbatiyk/features/notifications/data/datasources/local/notifications_local_datasource.dart';
import 'package:talbatiyk/features/notifications/data/datasources/remote/notifications_remote_datasource.dart';
import 'package:talbatiyk/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';
import 'package:talbatiyk/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:talbatiyk/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  test(
    'notification providers build the real local-first dependency chain',
    () {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          generatedApiClientProvider.overrideWithValue(
            GeneratedApiClient.create(baseUrl: 'http://127.0.0.1:8000/api/v1'),
          ),
        ],
      );

      addTearDown(database.close);
      addTearDown(container.dispose);

      expect(
        container.read(notificationsLocalDataSourceProvider),
        isA<NotificationsLocalDatasourceImpl>(),
      );

      expect(
        container.read(notificationsRemoteDataSourceProvider),
        isA<NotificationsRemoteDatasourceImpl>(),
      );

      expect(
        container.read(notificationsRepositoryProvider),
        isA<NotificationsRepositoryImpl>(),
      );

      expect(
        container.read(notificationsUseCaseProvider),
        isA<NotificationsUseCase>(),
      );
    },
  );

  test(
    'notification controller provider is isolated by explicit userId',
    () async {
      final repository = _ProviderFakeNotificationsRepository();

      repository.notificationsByUser['user-a'] = <NotificationsEntity>[
        _notification(id: 'a-1', title: 'User A'),
      ];

      repository.notificationsByUser['user-b'] = <NotificationsEntity>[
        _notification(id: 'b-1', title: 'User B'),
      ];

      repository.unreadCountByUser['user-a'] = 1;
      repository.unreadCountByUser['user-b'] = 1;

      final container = ProviderContainer(
        overrides: [
          notificationsUseCaseProvider.overrideWithValue(
            NotificationsUseCase(repository),
          ),
        ],
      );

      addTearDown(container.dispose);

      final subscriptionA = container.listen(
        notificationsProvider('user-a'),
        (_, _) {},
        fireImmediately: true,
      );

      final subscriptionB = container.listen(
        notificationsProvider('user-b'),
        (_, _) {},
        fireImmediately: true,
      );

      addTearDown(subscriptionA.close);
      addTearDown(subscriptionB.close);

      final controllerA = container.read(notificationsProvider('user-a'));

      final controllerB = container.read(notificationsProvider('user-b'));

      expect(controllerA, isA<NotificationsController>());
      expect(controllerB, isA<NotificationsController>());

      expect(identical(controllerA, controllerB), isFalse);

      expect(controllerA.userId, 'user-a');
      expect(controllerB.userId, 'user-b');

      await controllerA.load();
      await controllerB.load();

      expect(controllerA.state.notifications.single.id, 'a-1');

      expect(controllerB.state.notifications.single.id, 'b-1');

      expect(repository.listUserIds, containsAll(<String>['user-a', 'user-b']));
    },
  );
}

NotificationsEntity _notification({required String id, required String title}) {
  return NotificationsEntity(
    id: id,
    type: 'order_response_received',
    title: title,
    body: 'Notification body',
    data: const <String, dynamic>{},
    isRead: false,
    readAt: null,
    createdAt: DateTime.utc(2026, 9, 21, 18),
    updatedAt: DateTime.utc(2026, 9, 21, 18),
  );
}

final class _ProviderFakeNotificationsRepository
    implements NotificationsRepository {
  final Map<String, List<NotificationsEntity>> notificationsByUser =
      <String, List<NotificationsEntity>>{};

  final Map<String, int> unreadCountByUser = <String, int>{};

  final List<String> listUserIds = <String>[];

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    listUserIds.add(userId);

    return List<NotificationsEntity>.unmodifiable(
      notificationsByUser[userId] ?? const <NotificationsEntity>[],
    );
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) {
    throw StateError('Unexpected mutation in provider wiring test.');
  }

  @override
  Future<int> markAllRead({required String userId}) {
    throw StateError('Unexpected mutation in provider wiring test.');
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    return unreadCountByUser[userId] ?? 0;
  }
}

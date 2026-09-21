import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/notifications/domain/entities/notifications_entity.dart';
import 'package:talbatiyk/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:talbatiyk/features/notifications/domain/usecases/notifications_usecase.dart';
import 'package:talbatiyk/features/notifications/presentation/pages/notifications_page.dart';
import 'package:talbatiyk/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  group('NotificationsPage', () {
    testWidgets('loads only the explicit user and shows empty state', (
      tester,
    ) async {
      final repository = _FakeNotificationsRepository();

      final container = ProviderContainer(
        overrides: [
          notificationsUseCaseProvider.overrideWithValue(
            NotificationsUseCase(repository),
          ),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotificationsPage(userId: 'user-a')),
        ),
      );

      await tester.pumpAndSettle();

      expect(repository.listUserIds, <String>['user-a']);

      expect(repository.unreadCountUserIds, <String>['user-a']);

      expect(find.text('الإشعارات'), findsOneWidget);

      expect(find.text('لا توجد إشعارات'), findsOneWidget);
    });

    testWidgets(
      'renders notifications and marks an unread notification as read',
      (tester) async {
        final repository = _FakeNotificationsRepository();

        repository.notificationsByUser['user-a'] = <NotificationsEntity>[
          _notification(
            id: 'n-1',
            title: 'تم تحديث طلبك',
            body: 'وصل رد جديد على الطلب',
          ),
          _notification(
            id: 'n-2',
            title: 'إشعار مقروء',
            body: 'هذا الإشعار مقروء',
            isRead: true,
            readAt: DateTime.utc(2026, 9, 21, 20),
          ),
        ];

        repository.unreadCountByUser['user-a'] = 1;

        final container = ProviderContainer(
          overrides: [
            notificationsUseCaseProvider.overrideWithValue(
              NotificationsUseCase(repository),
            ),
          ],
        );

        addTearDown(container.dispose);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: NotificationsPage(userId: 'user-a')),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('تم تحديث طلبك'), findsOneWidget);

        expect(find.text('إشعار مقروء'), findsOneWidget);

        expect(
          find.byKey(const ValueKey<String>('notification-unread-n-1')),
          findsOneWidget,
        );

        repository.markReadResult = _notification(
          id: 'n-1',
          title: 'تم تحديث طلبك',
          body: 'وصل رد جديد على الطلب',
          isRead: true,
          readAt: DateTime.utc(2026, 9, 21, 21),
        );

        repository.unreadCountByUser['user-a'] = 0;

        await tester.tap(
          find.byKey(const ValueKey<String>('notification-tile-n-1')),
        );

        await tester.pumpAndSettle();

        expect(repository.markReadRequests, <(String, String)>[
          ('user-a', 'n-1'),
        ]);

        expect(
          find.byKey(const ValueKey<String>('notification-unread-n-1')),
          findsNothing,
        );
      },
    );

    testWidgets('mark all read action is wired to the current user', (
      tester,
    ) async {
      final repository = _FakeNotificationsRepository();

      repository.notificationsByUser['user-a'] = <NotificationsEntity>[
        _notification(id: 'n-1', title: 'الأول', body: 'Body 1'),
        _notification(id: 'n-2', title: 'الثاني', body: 'Body 2'),
      ];

      repository.unreadCountByUser['user-a'] = 2;

      repository.onMarkAllRead = (userId) {
        final current =
            repository.notificationsByUser[userId] ??
            const <NotificationsEntity>[];

        repository.notificationsByUser[userId] = <NotificationsEntity>[
          for (final item in current)
            _notification(
              id: item.id,
              title: item.title,
              body: item.body,
              isRead: true,
              readAt: DateTime.utc(2026, 9, 21, 22),
            ),
        ];

        repository.unreadCountByUser[userId] = 0;
      };

      final container = ProviderContainer(
        overrides: [
          notificationsUseCaseProvider.overrideWithValue(
            NotificationsUseCase(repository),
          ),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotificationsPage(userId: 'user-a')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('تحديد الكل كمقروء'), findsOneWidget);

      await tester.tap(find.text('تحديد الكل كمقروء'));

      await tester.pumpAndSettle();

      expect(repository.markAllReadUserIds, <String>['user-a']);

      expect(find.text('تحديد الكل كمقروء'), findsNothing);
    });

    testWidgets('shows failure state and retry reloads the same user', (
      tester,
    ) async {
      final repository = _FakeNotificationsRepository(
        listError: StateError('network failure'),
      );

      final container = ProviderContainer(
        overrides: [
          notificationsUseCaseProvider.overrideWithValue(
            NotificationsUseCase(repository),
          ),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: NotificationsPage(userId: 'user-a')),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      repository.listError = null;

      repository.notificationsByUser['user-a'] = <NotificationsEntity>[
        _notification(
          id: 'n-after-retry',
          title: 'تم التحميل',
          body: 'نجحت إعادة المحاولة',
        ),
      ];

      repository.unreadCountByUser['user-a'] = 1;

      await tester.tap(find.text('إعادة المحاولة'));

      await tester.pumpAndSettle();

      expect(find.text('تم التحميل'), findsOneWidget);

      expect(repository.listUserIds, <String>['user-a', 'user-a']);
    });
  });
}

NotificationsEntity _notification({
  required String id,
  required String title,
  required String body,
  bool isRead = false,
  DateTime? readAt,
}) {
  return NotificationsEntity(
    id: id,
    type: 'order_response_received',
    title: title,
    body: body,
    data: const <String, dynamic>{'order_id': 'order-1'},
    isRead: isRead,
    readAt: readAt,
    createdAt: DateTime.utc(2026, 9, 21, 18),
    updatedAt: readAt ?? DateTime.utc(2026, 9, 21, 18),
  );
}

final class _FakeNotificationsRepository implements NotificationsRepository {
  _FakeNotificationsRepository({this.listError});

  final Map<String, List<NotificationsEntity>> notificationsByUser =
      <String, List<NotificationsEntity>>{};

  final Map<String, int> unreadCountByUser = <String, int>{};

  final List<String> listUserIds = <String>[];

  final List<String> unreadCountUserIds = <String>[];

  final List<(String, String)> markReadRequests = <(String, String)>[];

  final List<String> markAllReadUserIds = <String>[];

  Object? listError;
  Object? markReadError;
  Object? markAllReadError;
  Object? unreadCountError;

  NotificationsEntity? markReadResult;

  void Function(String userId)? onMarkAllRead;

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    listUserIds.add(userId);

    final failure = listError;

    if (failure != null) {
      throw failure;
    }

    return List<NotificationsEntity>.unmodifiable(
      notificationsByUser[userId] ?? const <NotificationsEntity>[],
    );
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) async {
    markReadRequests.add((userId, notificationId));

    final failure = markReadError;

    if (failure != null) {
      throw failure;
    }

    final result = markReadResult;

    if (result == null) {
      throw StateError('markReadResult is not configured.');
    }

    final current =
        notificationsByUser[userId] ?? const <NotificationsEntity>[];

    notificationsByUser[userId] = <NotificationsEntity>[
      for (final item in current)
        if (item.id == result.id) result else item,
    ];

    return result;
  }

  @override
  Future<int> markAllRead({required String userId}) async {
    markAllReadUserIds.add(userId);

    final failure = markAllReadError;

    if (failure != null) {
      throw failure;
    }

    onMarkAllRead?.call(userId);

    return unreadCountByUser[userId] ?? 0;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    unreadCountUserIds.add(userId);

    final failure = unreadCountError;

    if (failure != null) {
      throw failure;
    }

    return unreadCountByUser[userId] ?? 0;
  }
}

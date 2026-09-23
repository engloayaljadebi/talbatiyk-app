import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/notifications/data/datasources/local/notifications_local_datasource.dart';
import 'package:talbatiyk/features/notifications/data/models/notifications_model.dart';

void main() {
  late AppDatabase database;
  late NotificationsLocalDatasource localDataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    localDataSource = NotificationsLocalDatasourceImpl(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Notifications local cache', () {
    test(
      'stores a user-scoped snapshot newest first and collapses duplicate ids',
      () async {
        await localDataSource.replaceNotifications(
          userId: 'user-a',
          notifications: [
            _notification(
              id: 'notification-old',
              title: 'Old',
              createdAt: DateTime.utc(2026, 9, 18, 10),
            ),
            _notification(
              id: 'notification-shared',
              title: 'First version',
              createdAt: DateTime.utc(2026, 9, 19, 10),
            ),
            _notification(
              id: 'notification-shared',
              title: 'Latest version',
              createdAt: DateTime.utc(2026, 9, 20, 10),
            ),
          ],
        );

        final cached = await localDataSource.getNotifications(userId: 'user-a');

        expect(cached, hasLength(2));

        expect(cached[0].id, 'notification-shared');
        expect(cached[0].title, 'Latest version');

        expect(cached[1].id, 'notification-old');
      },
    );

    test(
      'replacing one user snapshot never removes another user notifications',
      () async {
        await localDataSource.replaceNotifications(
          userId: 'user-a',
          notifications: [
            _notification(
              id: 'a-old',
              title: 'A old',
              createdAt: DateTime.utc(2026, 9, 18),
            ),
          ],
        );

        await localDataSource.replaceNotifications(
          userId: 'user-b',
          notifications: [
            _notification(
              id: 'b-kept',
              title: 'B kept',
              createdAt: DateTime.utc(2026, 9, 19),
            ),
          ],
        );

        await localDataSource.replaceNotifications(
          userId: 'user-a',
          notifications: [
            _notification(
              id: 'a-new',
              title: 'A new',
              createdAt: DateTime.utc(2026, 9, 20),
            ),
          ],
        );

        final userA = await localDataSource.getNotifications(userId: 'user-a');

        final userB = await localDataSource.getNotifications(userId: 'user-b');

        expect(userA.map((item) => item.id), ['a-new']);
        expect(userB.map((item) => item.id), ['b-kept']);
      },
    );

    test(
      'same server notification id is isolated between different users',
      () async {
        const sharedId = '11111111-1111-4111-8111-111111111111';

        await localDataSource.replaceNotifications(
          userId: 'user-a',
          notifications: [
            _notification(
              id: sharedId,
              title: 'User A copy',
              createdAt: DateTime.utc(2026, 9, 20, 8),
            ),
          ],
        );

        await localDataSource.replaceNotifications(
          userId: 'user-b',
          notifications: [
            _notification(
              id: sharedId,
              title: 'User B copy',
              createdAt: DateTime.utc(2026, 9, 20, 9),
            ),
          ],
        );

        final userA = await localDataSource.getNotifications(userId: 'user-a');

        final userB = await localDataSource.getNotifications(userId: 'user-b');

        expect(userA.single.title, 'User A copy');
        expect(userB.single.title, 'User B copy');
      },
    );

    test('markRead changes only the requested user copy', () async {
      const sharedId = '22222222-2222-4222-8222-222222222222';

      final readAt = DateTime.utc(2026, 9, 20, 12, 30);

      await localDataSource.replaceNotifications(
        userId: 'user-a',
        notifications: [
          _notification(
            id: sharedId,
            title: 'A unread',
            createdAt: DateTime.utc(2026, 9, 20, 10),
          ),
        ],
      );

      await localDataSource.replaceNotifications(
        userId: 'user-b',
        notifications: [
          _notification(
            id: sharedId,
            title: 'B unread',
            createdAt: DateTime.utc(2026, 9, 20, 10),
          ),
        ],
      );

      final updated = await localDataSource.markRead(
        userId: 'user-a',
        notificationId: sharedId,
        readAt: readAt,
      );

      expect(updated, isNotNull);
      expect(updated!.isRead, isTrue);
      expect(updated.readAt, readAt);

      final userB = await localDataSource.getNotifications(userId: 'user-b');

      expect(userB.single.isRead, isFalse);
      expect(userB.single.readAt, isNull);
    });

    test('markAllRead and unreadCount are scoped to one user', () async {
      final readAt = DateTime.utc(2026, 9, 20, 13);

      await localDataSource.replaceNotifications(
        userId: 'user-a',
        notifications: [
          _notification(
            id: 'a-1',
            title: 'A1',
            createdAt: DateTime.utc(2026, 9, 20, 11),
          ),
          _notification(
            id: 'a-2',
            title: 'A2',
            createdAt: DateTime.utc(2026, 9, 20, 10),
          ),
        ],
      );

      await localDataSource.replaceNotifications(
        userId: 'user-b',
        notifications: [
          _notification(
            id: 'b-1',
            title: 'B1',
            createdAt: DateTime.utc(2026, 9, 20, 9),
          ),
        ],
      );

      expect(await localDataSource.getUnreadCount(userId: 'user-a'), 2);

      expect(await localDataSource.getUnreadCount(userId: 'user-b'), 1);

      final updatedCount = await localDataSource.markAllRead(
        userId: 'user-a',
        readAt: readAt,
      );

      expect(updatedCount, 2);

      expect(await localDataSource.getUnreadCount(userId: 'user-a'), 0);

      expect(await localDataSource.getUnreadCount(userId: 'user-b'), 1);

      final userA = await localDataSource.getNotifications(userId: 'user-a');

      expect(
        userA.every((item) => item.isRead && item.readAt == readAt),
        isTrue,
      );
    });
  });
}

NotificationModel _notification({
  required String id,
  required String title,
  required DateTime createdAt,
  bool isRead = false,
  DateTime? readAt,
}) {
  return NotificationModel(
    id: id,
    type: 'order_response_received',
    title: title,
    body: 'Notification body',
    data: const <String, dynamic>{'order_id': 'order-1'},
    isRead: isRead,
    readAt: readAt,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../models/notifications_model.dart';

abstract class NotificationsLocalDatasource {
  Future<List<NotificationModel>> getNotifications({required String userId});

  Future<void> replaceNotifications({
    required String userId,
    required List<NotificationModel> notifications,
  });

  Future<NotificationModel?> markRead({
    required String userId,
    required String notificationId,
    required DateTime readAt,
  });

  Future<int> markAllRead({required String userId, required DateTime readAt});

  Future<int> getUnreadCount({required String userId});
}

final class NotificationsLocalDatasourceImpl
    implements NotificationsLocalDatasource {
  NotificationsLocalDatasourceImpl(this.database);

  final AppDatabase database;

  @override
  Future<List<NotificationModel>> getNotifications({
    required String userId,
  }) async {
    final query = database.select(database.notificationRecords)
      ..where((table) => table.userId.equals(userId))
      ..orderBy([
        (table) => OrderingTerm.desc(table.createdAt),
        (table) => OrderingTerm.desc(table.id),
      ]);

    final records = await query.get();

    return List<NotificationModel>.unmodifiable(records.map(_toModel));
  }

  @override
  Future<void> replaceNotifications({
    required String userId,
    required List<NotificationModel> notifications,
  }) async {
    final notificationsById = <String, NotificationModel>{
      for (final notification in notifications) notification.id: notification,
    };

    await database.transaction(() async {
      await (database.delete(
        database.notificationRecords,
      )..where((table) => table.userId.equals(userId))).go();

      for (final notification in notificationsById.values) {
        await database
            .into(database.notificationRecords)
            .insertOnConflictUpdate(
              NotificationRecordsCompanion.insert(
                userId: userId,
                id: notification.id,
                type: notification.type,
                title: notification.title,
                body: notification.body,
                dataJson: Value(jsonEncode(notification.data)),
                isRead: Value(notification.isRead),
                readAt: Value(notification.readAt?.toUtc()),
                createdAt: notification.createdAt.toUtc(),
                updatedAt: notification.updatedAt.toUtc(),
              ),
            );
      }
    });
  }

  @override
  Future<NotificationModel?> markRead({
    required String userId,
    required String notificationId,
    required DateTime readAt,
  }) async {
    final existing =
        await (database.select(database.notificationRecords)..where(
              (table) =>
                  table.userId.equals(userId) & table.id.equals(notificationId),
            ))
            .getSingleOrNull();

    if (existing == null) {
      return null;
    }

    if (!existing.isRead || existing.readAt == null) {
      await (database.update(database.notificationRecords)..where(
            (table) =>
                table.userId.equals(userId) & table.id.equals(notificationId),
          ))
          .write(
            NotificationRecordsCompanion(
              isRead: const Value(true),
              readAt: Value(readAt.toUtc()),
            ),
          );
    }

    final updated =
        await (database.select(database.notificationRecords)..where(
              (table) =>
                  table.userId.equals(userId) & table.id.equals(notificationId),
            ))
            .getSingle();

    return _toModel(updated);
  }

  @override
  Future<int> markAllRead({required String userId, required DateTime readAt}) {
    return (database.update(database.notificationRecords)..where(
          (table) => table.userId.equals(userId) & table.isRead.equals(false),
        ))
        .write(
          NotificationRecordsCompanion(
            isRead: const Value(true),
            readAt: Value(readAt.toUtc()),
          ),
        );
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    final records =
        await (database.select(database.notificationRecords)..where(
              (table) =>
                  table.userId.equals(userId) & table.isRead.equals(false),
            ))
            .get();

    return records.length;
  }

  NotificationModel _toModel(NotificationRecord record) {
    return NotificationModel(
      id: record.id,
      type: record.type,
      title: record.title,
      body: record.body,
      data: NotificationModel.decodeData(record.dataJson),
      isRead: record.isRead,
      readAt: record.readAt?.toUtc(),
      createdAt: record.createdAt.toUtc(),
      updatedAt: record.updatedAt.toUtc(),
    );
  }
}

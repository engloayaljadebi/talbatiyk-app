import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/notifications_entity.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/local/notifications_local_datasource.dart';
import '../datasources/remote/notifications_remote_datasource.dart';
import '../mappers/notifications_mapper.dart';
import '../models/notifications_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final NotificationsLocalDatasource localDataSource;
  final NotificationsRemoteDatasource remoteDataSource;

  @override
  Future<List<NotificationsEntity>> getNotifications({
    required String userId,
  }) async {
    try {
      final List<NotificationModel> remoteNotifications = await remoteDataSource
          .getNotifications();

      await localDataSource.replaceNotifications(
        userId: userId,
        notifications: remoteNotifications,
      );
    } catch (error) {
      if (!_shouldUseLocalReadFallback(error)) {
        rethrow;
      }
    }

    final List<NotificationModel> localNotifications = await localDataSource
        .getNotifications(userId: userId);

    return List<NotificationsEntity>.unmodifiable(
      localNotifications.map(NotificationsMapper.toEntity),
    );
  }

  @override
  Future<NotificationsEntity> markRead({
    required String userId,
    required String notificationId,
  }) async {
    final notification = await remoteDataSource.markRead(
      notificationId: notificationId,
    );

    final readAt = notification.readAt;

    if (!notification.isRead || readAt == null) {
      throw const FormatException(
        'Remote mark-read result does not contain a valid read state.',
      );
    }

    await localDataSource.markRead(
      userId: userId,
      notificationId: notificationId,
      readAt: readAt,
    );

    return NotificationsMapper.toEntity(notification);
  }

  @override
  Future<int> markAllRead({required String userId}) async {
    final result = await remoteDataSource.markAllRead();

    await localDataSource.markAllRead(
      userId: userId,
      readAt: DateTime.now().toUtc(),
    );

    return result.unreadCount;
  }

  @override
  Future<int> getUnreadCount({required String userId}) async {
    try {
      return await remoteDataSource.getUnreadCount();
    } catch (error) {
      if (!_shouldUseLocalReadFallback(error)) {
        rethrow;
      }

      return localDataSource.getUnreadCount(userId: userId);
    }
  }

  bool _shouldUseLocalReadFallback(Object error) {
    if (_isConnectivityFailure(error)) {
      return true;
    }

    if (error is! DioException || error.type != DioExceptionType.badResponse) {
      return false;
    }

    final int? statusCode = error.response?.statusCode;

    if (statusCode == null) {
      return false;
    }

    return statusCode == 408 || statusCode == 429 || statusCode >= 500;
  }

  bool _isConnectivityFailure(Object error) {
    if (error is! DioException) {
      return false;
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.unknown:
        return error.error is SocketException;

      default:
        return false;
    }
  }
}

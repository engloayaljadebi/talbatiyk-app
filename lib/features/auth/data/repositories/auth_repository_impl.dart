/*
|--------------------------------------------------------------------------
| Auth Repository Implementation
|--------------------------------------------------------------------------
|
| ينسق بين Laravel وToken Storage وVerified Session Storage.
| Domain يبقى معزولًا عن Dio/OpenAPI والتخزين المحلي.
|
| قواعد مهمة:
| - وجود Token محلي لا يكفي لإثبات صلاحية الجلسة.
| - نجاح /me يحدّث آخر Verified Session.
| - Offline fallback مسموح فقط للأخطاء المؤقتة المحددة.
| - 401 يلغي الجلسة المحلية، و403 يلغي الـVerified Session لمنع bypass Offline.
|
*/

import 'dart:io';

import 'package:dio/dio.dart';

import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_session_storage.dart';
import '../datasources/local/auth_token_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

/// تنفيذ مستودع المصادقة وتنسيق مصادرها داخل Data Layer.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._tokenStorage,
    required this._verifiedSessionStorage,
  });

  final VerifiedAuthSessionStorage _verifiedSessionStorage;
  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    final remoteSession = await _remoteDataSource.login(
      login: login,
      password: password,
      deviceName: deviceName,
    );

    try {
      final AuthSessionEntity session = remoteSession.toDomain();

      await _tokenStorage.saveAccessToken(remoteSession.accessToken);
      await _verifiedSessionStorage.saveVerifiedSession(session);

      return session;
    } catch (error, stackTrace) {
      // Laravel may already have created a token, so avoid leaving partial state.
      await _bestEffortCleanupAfterFailedLogin();

      // Preserve the original login failure and its stack trace.
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    final String? accessToken = await _tokenStorage.readAccessToken();

    if (accessToken == null) {
      return null;
    }

    _remoteDataSource.setAccessToken(accessToken);

    try {
      final user = await _remoteDataSource.me();

      final AuthSessionEntity session = AuthSessionEntity(
        user: user.toDomain(),
      );

      await _verifiedSessionStorage.saveVerifiedSession(session);

      return session;
    } on DioException catch (error) {
      if (error.response?.statusCode == 401) {
        // Invalid token is definitive: never fall back to a cached session.
        await _clearLocalSession();

        return null;
      }

      if (error.response?.statusCode == 403) {
        // /auth/me is protected by active.user. Drop the verified snapshot so
        // a later offline restart cannot reuse a session rejected by Laravel.
        // Keep the token so a future online retry can succeed after reactivation.
        await _verifiedSessionStorage.deleteVerifiedSession();

        rethrow;
      }

      if (_canRestoreFromVerifiedCache(error)) {
        final AuthSessionEntity? cachedSession = await _verifiedSessionStorage
            .readVerifiedSession();

        if (cachedSession != null) {
          return cachedSession;
        }
      }

      rethrow;
    }
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    final user = await _remoteDataSource.me();

    final AuthUserEntity domainUser = user.toDomain();

    // A successful /me is a fresh server verification.
    await _verifiedSessionStorage.saveVerifiedSession(
      AuthSessionEntity(user: domainUser),
    );

    return domainUser;
  }

  @override
  Future<void> logout() async {
    try {
      await _remoteDataSource.logout();
    } finally {
      // Local logout must complete even when the remote revoke fails.
      await _clearLocalSession();
    }
  }

  /// يسمح بالـoffline fallback فقط للأخطاء المؤقتة أو غير الحاسمة.
  bool _canRestoreFromVerifiedCache(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return true;

      case DioExceptionType.unknown:
        return error.error is SocketException;

      case DioExceptionType.badResponse:
        final int? statusCode = error.response?.statusCode;

        if (statusCode == null) {
          return false;
        }

        return statusCode == 408 ||
            statusCode == 429 ||
            (statusCode >= 500 && statusCode < 600);

      default:
        return false;
    }
  }

  Future<void> _clearLocalSession() async {
    _remoteDataSource.clearAccessToken();

    try {
      await _tokenStorage.deleteAccessToken();
    } finally {
      // Do not leave a verified snapshot if token cleanup partially fails.
      await _verifiedSessionStorage.deleteVerifiedSession();
    }
  }

  /// ينظف آثار Login المحلي والخادمي قدر الإمكان دون إخفاء الخطأ الأصلي.
  Future<void> _bestEffortCleanupAfterFailedLogin() async {
    try {
      await _remoteDataSource.logout();
    } catch (_) {
      // Best effort: cleanup failures must not replace the original login error.
    } finally {
      _remoteDataSource.clearAccessToken();
    }

    try {
      await _tokenStorage.deleteAccessToken();
    } catch (_) {
      // Best effort.
    }

    try {
      await _verifiedSessionStorage.deleteVerifiedSession();
    } catch (_) {
      // Best effort.
    }
  }
}

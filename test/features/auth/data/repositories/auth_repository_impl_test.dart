/*
|--------------------------------------------------------------------------
| Auth Repository Implementation Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار تسجيل الدخول وحفظ Access Token.
| - اختبار استعادة الجلسة عند وجود Token محفوظ.
| - اختبار عدم وجود جلسة محفوظة.
| - اختبار جلب المستخدم الحالي.
| - اختبار تنظيف الجلسة المحلية عند تسجيل الخروج.
| - اختبار معالجة فشل Secure Storage بعد تسجيل الدخول.
|
| تستخدم الاختبارات Fake DataSources حتى نختبر Repository
| بمعزل عن الشبكة وPlatform Channels.
|
*/

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

void main() {
  const userId = '11111111-1111-4111-8111-111111111111';

  UserResource createUser() {
    return UserResource(
      (builder) => builder
        ..id = userId
        ..username = 'test_user'
        ..displayName = 'Test User'
        ..status = 'active'
        ..lastLoginAt = '2026-08-11T00:00:00.000Z',
    );
  }

  AuthRegister201ResponseData createRemoteSession({
    String accessToken = 'server-access-token',
  }) {
    return AuthRegister201ResponseData(
      (builder) => builder
        ..user.replace(createUser())
        ..accessToken = accessToken
        ..tokenType = AuthRegister201ResponseDataTokenTypeEnum.bearer,
    );
  }

  group('AuthRepositoryImpl', () {
    late FakeAuthRemoteDataSource remoteDataSource;
    late FakeAuthTokenStorage tokenStorage;
    late AuthRepositoryImpl repository;

    setUp(() {
      remoteDataSource = FakeAuthRemoteDataSource(
        loginResult: createRemoteSession(),
        meResult: createUser(),
      );

      tokenStorage = FakeAuthTokenStorage();

      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        tokenStorage: tokenStorage,
      );
    });
    test('restoreSession deletes stored token when me returns 401', () async {
      tokenStorage.savedToken = 'expired-access-token';

      final requestOptions = RequestOptions(path: '/auth/me');

      remoteDataSource.meError = DioException(
        requestOptions: requestOptions,
        response: Response<void>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final session = await repository.restoreSession();

      expect(session, isNull);

      // تم وضع التوكن أولًا في Generated API Client.
      expect(remoteDataSource.setAccessTokenCalled, isTrue);

      // تم استدعاء /auth/me للتحقق من الجلسة.
      expect(remoteDataSource.meCalled, isTrue);

      // 401 يعني أن Bearer لم يعد صالحًا.
      expect(remoteDataSource.clearAccessTokenCalled, isTrue);

      // يجب حذف التوكن من Secure Storage.
      expect(tokenStorage.deleteCalled, isTrue);
      expect(tokenStorage.savedToken, isNull);

      // ويجب تنظيف Bearer الموجود في الذاكرة.
      expect(remoteDataSource.appliedAccessToken, isNull);
    });

    test('restoreSession preserves stored token on network failure', () async {
      tokenStorage.savedToken = 'stored-access-token';

      remoteDataSource.meError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        type: DioExceptionType.connectionError,
        error: Exception('network unavailable'),
      );

      await expectLater(
        repository.restoreSession(),
        throwsA(isA<DioException>()),
      );

      expect(remoteDataSource.meCalled, isTrue);

      // خطأ الشبكة لا يعني انتهاء الجلسة.
      expect(remoteDataSource.clearAccessTokenCalled, isFalse);

      // يجب الاحتفاظ بالتوكن حتى يعود الاتصال.
      expect(tokenStorage.deleteCalled, isFalse);
      expect(tokenStorage.savedToken, 'stored-access-token');
    });
    test(
      'login saves access token and returns mapped domain session',
      () async {
        final session = await repository.login(
          login: 'test_user',
          password: 'secret123',
          deviceName: 'flutter-test',
        );

        expect(remoteDataSource.loginCalled, isTrue);
        expect(remoteDataSource.receivedLogin, 'test_user');
        expect(remoteDataSource.receivedPassword, 'secret123');
        expect(remoteDataSource.receivedDeviceName, 'flutter-test');

        expect(tokenStorage.savedToken, 'server-access-token');

        expect(session.user.id, userId);
        expect(session.user.username, 'test_user');
        expect(session.user.displayName, 'Test User');
        expect(session.user.status, 'active');
        expect(session.user.isActive, isTrue);

        expect(
          session.user.lastLoginAt,
          DateTime.parse('2026-08-11T00:00:00.000Z'),
        );
      },
    );

    test('restoreSession returns null when no token is stored', () async {
      final session = await repository.restoreSession();

      expect(session, isNull);

      expect(remoteDataSource.setAccessTokenCalled, isFalse);

      expect(remoteDataSource.meCalled, isFalse);
    });

    test(
      'restoreSession restores bearer token and verifies user with me',
      () async {
        tokenStorage.savedToken = 'stored-access-token';

        final session = await repository.restoreSession();

        expect(session, isNotNull);

        expect(remoteDataSource.appliedAccessToken, 'stored-access-token');

        expect(remoteDataSource.meCalled, isTrue);

        expect(session!.user.id, userId);

        expect(session.user.username, 'test_user');
      },
    );

    test('getCurrentUser returns mapped current user', () async {
      final user = await repository.getCurrentUser();

      expect(remoteDataSource.meCalled, isTrue);

      expect(user.id, userId);
      expect(user.username, 'test_user');
      expect(user.displayName, 'Test User');
      expect(user.isActive, isTrue);
    });

    test('logout clears local token even when remote logout fails', () async {
      tokenStorage.savedToken = 'stored-access-token';

      final remoteError = Exception('network unavailable');

      remoteDataSource.logoutError = remoteError;

      await expectLater(repository.logout(), throwsA(same(remoteError)));

      expect(remoteDataSource.logoutCalled, isTrue);
      expect(remoteDataSource.clearAccessTokenCalled, isTrue);
      expect(tokenStorage.deleteCalled, isTrue);
      expect(tokenStorage.savedToken, isNull);
    });

    test(
      'login revokes remote session when secure token storage fails',
      () async {
        final storageError = Exception('secure storage failed');

        tokenStorage.saveError = storageError;

        await expectLater(
          repository.login(
            login: 'test_user',
            password: 'secret123',
            deviceName: 'flutter-test',
          ),
          throwsA(same(storageError)),
        );

        expect(remoteDataSource.loginCalled, isTrue);

        // يجب محاولة إلغاء Token الذي أنشأه Laravel.
        expect(remoteDataSource.logoutCalled, isTrue);

        // نجاح logout في الـRemote يعني تنظيف Bearer أيضًا.
        expect(remoteDataSource.clearAccessTokenCalled, isTrue);
      },
    );
  });
}

/// Fake للمصدر البعيد حتى نختبر Repository بدون HTTP حقيقي.
final class FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  FakeAuthRemoteDataSource({required this.loginResult, required this.meResult});

  final AuthRegister201ResponseData loginResult;
  final UserResource meResult;

  bool loginCalled = false;
  bool meCalled = false;
  bool logoutCalled = false;
  bool setAccessTokenCalled = false;
  bool clearAccessTokenCalled = false;

  String? receivedLogin;
  String? receivedPassword;
  String? receivedDeviceName;
  String? appliedAccessToken;
  Object? meError;
  Object? logoutError;

  @override
  Future<AuthRegister201ResponseData> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    loginCalled = true;
    receivedLogin = login;
    receivedPassword = password;
    receivedDeviceName = deviceName;

    return loginResult;
  }

  @override
  Future<UserResource> me() async {
    meCalled = true;

    final error = meError;

    if (error != null) {
      throw error;
    }

    return meResult;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;

    final error = logoutError;

    if (error != null) {
      throw error;
    }

    // يحاكي السلوك الحقيقي لـAuthRemoteDataSourceImpl.
    clearAccessToken();
  }

  @override
  void setAccessToken(String token) {
    setAccessTokenCalled = true;
    appliedAccessToken = token;
  }

  @override
  void clearAccessToken() {
    clearAccessTokenCalled = true;
    appliedAccessToken = null;
  }
}

/// Fake للتخزين الآمن حتى نختبر Repository بدون Platform Channel.
final class FakeAuthTokenStorage implements AuthTokenStorage {
  String? savedToken;

  bool saveCalled = false;
  bool readCalled = false;
  bool deleteCalled = false;

  Object? saveError;

  @override
  Future<void> saveAccessToken(String token) async {
    saveCalled = true;

    final error = saveError;

    if (error != null) {
      throw error;
    }

    savedToken = token;
  }

  @override
  Future<String?> readAccessToken() async {
    readCalled = true;

    return savedToken;
  }

  @override
  Future<void> deleteAccessToken() async {
    deleteCalled = true;
    savedToken = null;
  }

  @override
  Future<bool> hasAccessToken() async {
    return savedToken != null;
  }
}

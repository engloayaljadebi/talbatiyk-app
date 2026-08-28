/*
|--------------------------------------------------------------------------
| Auth Repository Implementation Tests
|--------------------------------------------------------------------------
|
| تغطي اختبارات AuthRepositoryImpl:
| login/restoreSession/getCurrentUser/logout،
| Verified Session، Offline fallback، وسياسات 401/403 والتنظيف.
|
*/

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_session_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

void main() {
  const String userId = '11111111-1111-4111-8111-111111111111';

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

    late FakeVerifiedAuthSessionStorage verifiedSessionStorage;

    late AuthRepositoryImpl repository;

    setUp(() {
      remoteDataSource = FakeAuthRemoteDataSource(
        loginResult: createRemoteSession(),
        meResult: createUser(),
      );

      tokenStorage = FakeAuthTokenStorage();

      verifiedSessionStorage = FakeVerifiedAuthSessionStorage();

      repository = AuthRepositoryImpl(
        remoteDataSource: remoteDataSource,
        tokenStorage: tokenStorage,
        verifiedSessionStorage: verifiedSessionStorage,
      );
    });

    test('restoreSession deletes stored token when me returns 401', () async {
      tokenStorage.savedToken = 'expired-access-token';

      verifiedSessionStorage.session = _createCachedSession();

      final RequestOptions requestOptions = RequestOptions(path: '/auth/me');

      remoteDataSource.meError = DioException(
        requestOptions: requestOptions,
        response: Response<void>(
          requestOptions: requestOptions,
          statusCode: 401,
        ),
        type: DioExceptionType.badResponse,
      );

      final AuthSessionEntity? session = await repository.restoreSession();

      expect(session, isNull);

      expect(remoteDataSource.setAccessTokenCalled, isTrue);

      expect(remoteDataSource.meCalled, isTrue);

      expect(remoteDataSource.clearAccessTokenCalled, isTrue);

      expect(tokenStorage.deleteCalled, isTrue);

      expect(tokenStorage.savedToken, isNull);

      expect(verifiedSessionStorage.deleteCalled, isTrue);

      expect(verifiedSessionStorage.session, isNull);

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

      expect(verifiedSessionStorage.readCalled, isTrue);

      expect(verifiedSessionStorage.session, isNull);

      expect(remoteDataSource.clearAccessTokenCalled, isFalse);

      expect(tokenStorage.deleteCalled, isFalse);

      expect(tokenStorage.savedToken, 'stored-access-token');
    });

    test(
      'restoreSession uses verified cached session on network failure',
      () async {
        tokenStorage.savedToken = 'stored-access-token';

        verifiedSessionStorage.session = _createCachedSession();

        remoteDataSource.meError = DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          type: DioExceptionType.connectionError,
          error: Exception('network unavailable'),
        );

        final AuthSessionEntity? session = await repository.restoreSession();

        expect(session, isNotNull);

        expect(session!.user.id, userId);

        expect(session.user.username, 'cached_user');

        expect(verifiedSessionStorage.readCalled, isTrue);

        expect(tokenStorage.savedToken, 'stored-access-token');

        expect(remoteDataSource.clearAccessTokenCalled, isFalse);
      },
    );

    test(
      'restoreSession uses verified cached session when me returns 503',
      () async {
        tokenStorage.savedToken = 'stored-access-token';

        verifiedSessionStorage.session = _createCachedSession();

        final RequestOptions requestOptions = RequestOptions(path: '/auth/me');

        remoteDataSource.meError = DioException(
          requestOptions: requestOptions,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 503,
          ),
          type: DioExceptionType.badResponse,
        );

        final AuthSessionEntity? session = await repository.restoreSession();

        expect(session, isNotNull);

        expect(session!.user.username, 'cached_user');

        expect(verifiedSessionStorage.readCalled, isTrue);

        expect(tokenStorage.savedToken, 'stored-access-token');

        expect(verifiedSessionStorage.deleteCalled, isFalse);
      },
    );

    test('restoreSession invalidates verified cache after HTTP 403', () async {
      tokenStorage.savedToken = 'stored-access-token';
      verifiedSessionStorage.session = _createCachedSession();

      final RequestOptions requestOptions = RequestOptions(path: '/auth/me');

      remoteDataSource.meError = DioException(
        requestOptions: requestOptions,
        response: Response<void>(
          requestOptions: requestOptions,
          statusCode: 403,
        ),
        type: DioExceptionType.badResponse,
      );

      await expectLater(
        repository.restoreSession(),
        throwsA(isA<DioException>()),
      );

      expect(verifiedSessionStorage.readCalled, isFalse);

      expect(tokenStorage.savedToken, 'stored-access-token');

      expect(tokenStorage.deleteCalled, isFalse);

      expect(verifiedSessionStorage.deleteCalled, isTrue);

      expect(verifiedSessionStorage.session, isNull);
    });
    test(
      'restoreSession cannot use cache after previous 403 invalidated it',
      () async {
        tokenStorage.savedToken = 'stored-access-token';
        verifiedSessionStorage.session = _createCachedSession();

        final RequestOptions requestOptions = RequestOptions(path: '/auth/me');

        remoteDataSource.meError = DioException(
          requestOptions: requestOptions,
          response: Response<void>(
            requestOptions: requestOptions,
            statusCode: 403,
          ),
          type: DioExceptionType.badResponse,
        );

        await expectLater(
          repository.restoreSession(),
          throwsA(isA<DioException>()),
        );

        expect(verifiedSessionStorage.session, isNull);

        verifiedSessionStorage.readCalled = false;

        remoteDataSource.meError = DioException(
          requestOptions: RequestOptions(path: '/auth/me'),
          type: DioExceptionType.connectionError,
          error: Exception('network unavailable'),
        );

        await expectLater(
          repository.restoreSession(),
          throwsA(isA<DioException>()),
        );

        expect(verifiedSessionStorage.readCalled, isTrue);

        expect(verifiedSessionStorage.session, isNull);

        expect(tokenStorage.savedToken, 'stored-access-token');
      },
    );
    test(
      'login saves access token and returns mapped domain session',
      () async {
        final AuthSessionEntity session = await repository.login(
          login: 'test_user',
          password: 'secret123',
          deviceName: 'flutter-test',
        );

        expect(remoteDataSource.loginCalled, isTrue);

        expect(remoteDataSource.receivedLogin, 'test_user');

        expect(remoteDataSource.receivedPassword, 'secret123');

        expect(remoteDataSource.receivedDeviceName, 'flutter-test');

        expect(tokenStorage.savedToken, 'server-access-token');

        expect(verifiedSessionStorage.saveCalled, isTrue);

        expect(verifiedSessionStorage.session, isNotNull);

        expect(verifiedSessionStorage.session!.user.id, userId);

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
      final AuthSessionEntity? session = await repository.restoreSession();

      expect(session, isNull);

      expect(remoteDataSource.setAccessTokenCalled, isFalse);

      expect(remoteDataSource.meCalled, isFalse);

      expect(verifiedSessionStorage.readCalled, isFalse);
    });

    test(
      'restoreSession restores bearer token and verifies user with me',
      () async {
        tokenStorage.savedToken = 'stored-access-token';

        final AuthSessionEntity? session = await repository.restoreSession();

        expect(session, isNotNull);

        expect(remoteDataSource.appliedAccessToken, 'stored-access-token');

        expect(remoteDataSource.meCalled, isTrue);

        expect(session!.user.id, userId);

        expect(session.user.username, 'test_user');

        expect(verifiedSessionStorage.saveCalled, isTrue);

        expect(verifiedSessionStorage.session, isNotNull);

        expect(verifiedSessionStorage.session!.user.id, userId);
      },
    );

    test('getCurrentUser returns mapped current user', () async {
      final AuthUserEntity user = await repository.getCurrentUser();

      expect(remoteDataSource.meCalled, isTrue);

      expect(user.id, userId);

      expect(user.username, 'test_user');

      expect(user.displayName, 'Test User');

      expect(user.isActive, isTrue);

      expect(verifiedSessionStorage.saveCalled, isTrue);

      expect(verifiedSessionStorage.session, isNotNull);

      expect(verifiedSessionStorage.session!.user.id, userId);
    });

    test('logout clears local token even when remote logout fails', () async {
      tokenStorage.savedToken = 'stored-access-token';

      verifiedSessionStorage.session = _createCachedSession();

      final Exception remoteError = Exception('network unavailable');

      remoteDataSource.logoutError = remoteError;

      await expectLater(repository.logout(), throwsA(same(remoteError)));

      expect(remoteDataSource.logoutCalled, isTrue);

      expect(remoteDataSource.clearAccessTokenCalled, isTrue);

      expect(tokenStorage.deleteCalled, isTrue);

      expect(tokenStorage.savedToken, isNull);

      expect(verifiedSessionStorage.deleteCalled, isTrue);

      expect(verifiedSessionStorage.session, isNull);
    });

    test(
      'login revokes remote session when secure token storage fails',
      () async {
        final Exception storageError = Exception('secure storage failed');

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

        expect(remoteDataSource.logoutCalled, isTrue);

        expect(remoteDataSource.clearAccessTokenCalled, isTrue);

        expect(tokenStorage.deleteCalled, isTrue);

        expect(verifiedSessionStorage.deleteCalled, isTrue);

        expect(verifiedSessionStorage.session, isNull);
      },
    );
    test(
      'login clears durable auth state when verified session storage fails',
      () async {
        final storageError = Exception('verified session storage failed');

        verifiedSessionStorage.saveError = storageError;

        await expectLater(
          repository.login(
            login: 'test_user',
            password: 'secret123',
            deviceName: 'flutter-test',
          ),
          throwsA(same(storageError)),
        );

        expect(remoteDataSource.loginCalled, isTrue);
        expect(remoteDataSource.logoutCalled, isTrue);

        expect(tokenStorage.deleteCalled, isTrue);
        expect(tokenStorage.savedToken, isNull);

        expect(verifiedSessionStorage.deleteCalled, isTrue);
        expect(verifiedSessionStorage.session, isNull);

        expect(remoteDataSource.clearAccessTokenCalled, isTrue);
      },
    );
  });
}

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

    final Object? error = meError;

    if (error != null) {
      throw error;
    }

    return meResult;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;

    final Object? error = logoutError;

    if (error != null) {
      throw error;
    }

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

final class FakeAuthTokenStorage implements AuthTokenStorage {
  String? savedToken;

  bool saveCalled = false;
  bool readCalled = false;
  bool deleteCalled = false;

  Object? saveError;

  @override
  Future<void> saveAccessToken(String token) async {
    saveCalled = true;

    final Object? error = saveError;

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

final class FakeVerifiedAuthSessionStorage
    implements VerifiedAuthSessionStorage {
  AuthSessionEntity? session;

  bool saveCalled = false;
  bool readCalled = false;
  bool deleteCalled = false;

  Object? saveError;

  @override
  Future<void> saveVerifiedSession(AuthSessionEntity session) async {
    saveCalled = true;

    final Object? error = saveError;

    if (error != null) {
      throw error;
    }

    this.session = session;
  }

  @override
  Future<AuthSessionEntity?> readVerifiedSession() async {
    readCalled = true;

    return session;
  }

  @override
  Future<void> deleteVerifiedSession() async {
    deleteCalled = true;
    session = null;
  }
}

AuthSessionEntity _createCachedSession() {
  return AuthSessionEntity(
    user: AuthUserEntity(
      id: '11111111-1111-4111-8111-111111111111',
      username: 'cached_user',
      displayName: 'Cached User',
      status: 'active',
      lastLoginAt: null,
      contacts: <AuthContactEntity>[],
    ),
  );
}

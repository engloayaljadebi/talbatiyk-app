import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_session_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk/features/auth/data/repositories/auth_repository_impl.dart';
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

  AuthRegister201ResponseData createRemoteSession() {
    return AuthRegister201ResponseData(
      (builder) => builder
        ..user.replace(createUser())
        ..accessToken = 'server-access-token'
        ..tokenType = AuthRegister201ResponseDataTokenTypeEnum.bearer,
    );
  }

  test(
    'restores verified session after repository restart while offline',
    () async {
      final secureStore = _FakeSecureKeyValueStore();

      // المرحلة الأولى: Login Online وحفظ durable auth state.
      final onlineRemote = _FakeAuthRemoteDataSource(
        loginResult: createRemoteSession(),
        meResult: createUser(),
      );

      final onlineRepository = AuthRepositoryImpl(
        remoteDataSource: onlineRemote,
        tokenStorage: AuthTokenStorageImpl(secureStore),
        verifiedSessionStorage: VerifiedAuthSessionStorageImpl(secureStore),
      );

      final onlineSession = await onlineRepository.login(
        login: 'test_user',
        password: 'secret123',
        deviceName: 'flutter-test',
      );

      expect(onlineSession.user.id, userId);

      // المرحلة الثانية: نحاكي Process restart بإنشاء
      // Repository وStorage instances جديدة فوق نفس durable store.
      final offlineRemote = _FakeAuthRemoteDataSource(
        loginResult: createRemoteSession(),
        meResult: createUser(),
      );

      offlineRemote.meError = DioException(
        requestOptions: RequestOptions(path: '/auth/me'),
        type: DioExceptionType.connectionError,
        error: Exception('network unavailable'),
      );

      final restartedRepository = AuthRepositoryImpl(
        remoteDataSource: offlineRemote,
        tokenStorage: AuthTokenStorageImpl(secureStore),
        verifiedSessionStorage: VerifiedAuthSessionStorageImpl(secureStore),
      );

      final restoredSession = await restartedRepository.restoreSession();

      expect(restoredSession, isNotNull);
      expect(restoredSession!.user.id, userId);
      expect(restoredSession.user.username, 'test_user');

      // Startup ما زال يحاول server verification أولًا.
      expect(offlineRemote.meCalled, isTrue);

      // Token المستعاد يُعاد ربطه بالـAPI client.
      expect(offlineRemote.appliedAccessToken, 'server-access-token');
    },
  );
}

final class _FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }
}

final class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  _FakeAuthRemoteDataSource({
    required this.loginResult,
    required this.meResult,
  });

  final AuthRegister201ResponseData loginResult;
  final UserResource meResult;

  Object? meError;

  bool meCalled = false;
  String? appliedAccessToken;

  @override
  Future<AuthRegister201ResponseData> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    final String token = loginResult.accessToken;

    setAccessToken(token);

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
    clearAccessToken();
  }

  @override
  void setAccessToken(String token) {
    appliedAccessToken = token;
  }

  @override
  void clearAccessToken() {
    appliedAccessToken = null;
  }
}

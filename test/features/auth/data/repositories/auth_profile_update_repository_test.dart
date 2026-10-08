import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_session_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:talbatiyk/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

void main() {
  const String userId = '11111111-1111-4111-8111-111111111111';

  UserResource updatedUser() {
    return UserResource(
      (builder) => builder
        ..id = userId
        ..username = 'new_username'
        ..displayName = 'New Display Name'
        ..status = 'active'
        ..lastLoginAt = '2026-09-23T20:00:00.000Z',
    );
  }

  AuthSessionEntity originalSession() {
    return const AuthSessionEntity(
      user: AuthUserEntity(
        id: userId,
        username: 'old_username',
        displayName: 'Old Display Name',
        status: 'active',
        lastLoginAt: null,
        contacts: <AuthContactEntity>[],
      ),
    );
  }

  group('AuthRepository profile update', () {
    test(
      'updateProfile maps server user and replaces verified session',
      () async {
        final remote = _ProfileRemoteDataSource(result: updatedUser());

        final tokenStorage = _ProfileTokenStorage();

        final verifiedStorage = _ProfileVerifiedSessionStorage()
          ..session = originalSession();

        final AuthRepository repository = AuthRepositoryImpl(
          remoteDataSource: remote,
          tokenStorage: tokenStorage,
          verifiedSessionStorage: verifiedStorage,
        );

        final AuthUserEntity user = await repository.updateProfile(
          username: 'new_username',
          displayName: 'New Display Name',
        );

        expect(remote.updateProfileCalled, isTrue);
        expect(remote.receivedUsername, 'new_username');

        expect(remote.receivedDisplayName, 'New Display Name');

        expect(user.id, userId);
        expect(user.username, 'new_username');

        expect(user.displayName, 'New Display Name');

        expect(user.status, 'active');

        expect(user.lastLoginAt, DateTime.parse('2026-09-23T20:00:00.000Z'));

        expect(verifiedStorage.saveCalled, isTrue);
        expect(verifiedStorage.session, isNotNull);

        expect(verifiedStorage.session!.user.username, 'new_username');

        expect(verifiedStorage.session!.user.displayName, 'New Display Name');

        expect(tokenStorage.saveCalled, isFalse);
        expect(tokenStorage.deleteCalled, isFalse);
      },
    );

    test('failed remote update does not replace verified session', () async {
      final remoteError = Exception('profile update failed');

      final remote = _ProfileRemoteDataSource(
        result: updatedUser(),
        error: remoteError,
      );

      final tokenStorage = _ProfileTokenStorage();

      final verifiedStorage = _ProfileVerifiedSessionStorage()
        ..session = originalSession();

      final AuthRepository repository = AuthRepositoryImpl(
        remoteDataSource: remote,
        tokenStorage: tokenStorage,
        verifiedSessionStorage: verifiedStorage,
      );

      await expectLater(
        repository.updateProfile(displayName: 'Should Not Persist'),
        throwsA(same(remoteError)),
      );

      expect(remote.updateProfileCalled, isTrue);

      expect(verifiedStorage.saveCalled, isFalse);

      expect(verifiedStorage.session!.user.username, 'old_username');

      expect(verifiedStorage.session!.user.displayName, 'Old Display Name');

      expect(tokenStorage.saveCalled, isFalse);
      expect(tokenStorage.deleteCalled, isFalse);
    });
  });
}

final class _ProfileRemoteDataSource implements AuthRemoteDataSource {
  _ProfileRemoteDataSource({required this.result, this.error});

  final UserResource result;
  final Object? error;

  bool updateProfileCalled = false;

  String? receivedUsername;
  String? receivedDisplayName;

  @override
  Future<UserResource> updateProfile({
    String? username,
    String? displayName,
  }) async {
    updateProfileCalled = true;
    receivedUsername = username;
    receivedDisplayName = displayName;

    final Object? currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    return result;
  }

  @override
  Future<AuthRegister201ResponseData> login({
    required String login,
    required String password,
    required String deviceName,
  }) {
    throw StateError('login is outside this repository profile test.');
  }

  @override
  Future<UserResource> me() async {
    return result;
  }

  @override
  Future<void> logout() async {}

  @override
  void setAccessToken(String token) {}

  @override
  void clearAccessToken() {}
}

final class _ProfileTokenStorage implements AuthTokenStorage {
  bool saveCalled = false;
  bool deleteCalled = false;

  String? token;

  @override
  Future<void> saveAccessToken(String token) async {
    saveCalled = true;
    this.token = token;
  }

  @override
  Future<String?> readAccessToken() async {
    return token;
  }

  @override
  Future<void> deleteAccessToken() async {
    deleteCalled = true;
    token = null;
  }

  @override
  Future<bool> hasAccessToken() async {
    return token != null;
  }
}

final class _ProfileVerifiedSessionStorage
    implements VerifiedAuthSessionStorage {
  AuthSessionEntity? session;

  bool saveCalled = false;

  @override
  Future<void> saveVerifiedSession(AuthSessionEntity session) async {
    saveCalled = true;
    this.session = session;
  }

  @override
  Future<AuthSessionEntity?> readVerifiedSession() async {
    return session;
  }

  @override
  Future<void> deleteVerifiedSession() async {
    session = null;
  }
}

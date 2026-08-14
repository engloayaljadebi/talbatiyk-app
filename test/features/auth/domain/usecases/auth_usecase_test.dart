/*
|--------------------------------------------------------------------------
| Auth Use Case Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار تسجيل الدخول بالقيم الصحيحة.
| - اختبار تنظيف login وdeviceName من المسافات.
| - التأكد من عدم تعديل كلمة المرور.
| - رفض login الفارغ.
| - رفض كلمة المرور الفارغة.
| - رفض اسم الجهاز الفارغ.
| - اختبار استعادة الجلسة.
| - اختبار جلب المستخدم الحالي.
| - اختبار تسجيل الخروج.
|
| نستخدم Fake Repository حتى نختبر قواعد Domain فقط.
|
*/

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';

void main() {
  const user = AuthUserEntity(
    id: '11111111-1111-4111-8111-111111111111',
    username: 'test_user',
    displayName: 'Test User',
    status: 'active',
    lastLoginAt: null,
    contacts: <AuthContactEntity>[],
  );

  const session = AuthSessionEntity(user: user);

  group('AuthUseCase', () {
    late FakeAuthRepository repository;
    late AuthUseCase useCase;

    setUp(() {
      repository = FakeAuthRepository(
        loginResult: session,
        restoreResult: session,
        currentUserResult: user,
      );

      useCase = AuthUseCase(repository);
    });

    test('login forwards valid credentials to repository', () async {
      final result = await useCase.login(
        login: 'test_user',
        password: 'secret123',
        deviceName: 'flutter-test',
      );

      expect(result, same(session));

      expect(repository.loginCalled, isTrue);
      expect(repository.receivedLogin, 'test_user');
      expect(repository.receivedPassword, 'secret123');
      expect(repository.receivedDeviceName, 'flutter-test');
    });

    test('login trims login and deviceName before repository call', () async {
      await useCase.login(
        login: '   test_user   ',
        password: 'secret123',
        deviceName: '   flutter-test   ',
      );

      expect(repository.receivedLogin, 'test_user');

      expect(repository.receivedDeviceName, 'flutter-test');
    });

    test('login preserves password exactly as entered', () async {
      const password = '  secret 123  ';

      await useCase.login(
        login: 'test_user',
        password: password,
        deviceName: 'flutter-test',
      );

      expect(repository.receivedPassword, password);
    });

    test('login rejects empty login', () {
      expect(
        () => useCase.login(
          login: '   ',
          password: 'secret123',
          deviceName: 'flutter-test',
        ),
        throwsArgumentError,
      );

      expect(repository.loginCalled, isFalse);
    });

    test('login rejects empty password', () {
      expect(
        () => useCase.login(
          login: 'test_user',
          password: '',
          deviceName: 'flutter-test',
        ),
        throwsArgumentError,
      );

      expect(repository.loginCalled, isFalse);
    });

    test('login rejects empty deviceName', () {
      expect(
        () => useCase.login(
          login: 'test_user',
          password: 'secret123',
          deviceName: '   ',
        ),
        throwsArgumentError,
      );

      expect(repository.loginCalled, isFalse);
    });

    test('restoreSession returns repository session', () async {
      final result = await useCase.restoreSession();

      expect(repository.restoreSessionCalled, isTrue);
      expect(result, same(session));
    });

    test('getCurrentUser returns repository user', () async {
      final result = await useCase.getCurrentUser();

      expect(repository.getCurrentUserCalled, isTrue);
      expect(result, same(user));
    });

    test('logout delegates to repository', () async {
      await useCase.logout();

      expect(repository.logoutCalled, isTrue);
    });
  });
}

/// Fake Repository لاختبار AuthUseCase دون أي اعتماد
/// على الشبكة أو Secure Storage.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.loginResult,
    required this.restoreResult,
    required this.currentUserResult,
  });

  final AuthSessionEntity loginResult;
  final AuthSessionEntity? restoreResult;
  final AuthUserEntity currentUserResult;

  bool loginCalled = false;
  bool restoreSessionCalled = false;
  bool getCurrentUserCalled = false;
  bool logoutCalled = false;

  String? receivedLogin;
  String? receivedPassword;
  String? receivedDeviceName;

  @override
  Future<AuthSessionEntity> login({
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
  Future<AuthSessionEntity?> restoreSession() async {
    restoreSessionCalled = true;

    return restoreResult;
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    getCurrentUserCalled = true;

    return currentUserResult;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;
  }
}

/*
|--------------------------------------------------------------------------
| Auth Controller Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار الحالة الابتدائية.
| - اختبار استعادة جلسة موجودة.
| - اختبار عدم وجود جلسة محفوظة.
| - اختبار فشل استعادة الجلسة.
| - اختبار تسجيل الدخول الناجح والفاشل.
| - اختبار تسجيل الخروج الناجح.
| - اختبار تسجيل الخروج عند فشل الاتصال بالخادم.
| - التحقق من حالات loading أثناء العمليات.
|
| نستخدم AuthUseCase حقيقيًا مع Fake AuthRepository حتى يكون
| الاختبار قريبًا من التدفق الفعلي دون شبكة أو Secure Storage.
|
*/

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/states/auth_state.dart';

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

  group('AuthController', () {
    late FakeAuthRepository repository;
    late AuthUseCase useCase;
    late AuthController controller;

    setUp(() {
      repository = FakeAuthRepository(
        loginResult: session,
        restoreResult: session,
        currentUserResult: user,
      );

      useCase = AuthUseCase(repository);

      controller = AuthController(useCase, autoRestore: false);
    });

    tearDown(() {
      controller.dispose();
    });

    test('starts with initial state when autoRestore is disabled', () {
      expect(controller.state.status, AuthStatus.initial);

      expect(controller.state.session, isNull);

      expect(controller.state.errorMessage, isNull);

      expect(controller.state.isAuthenticated, isFalse);

      expect(controller.state.isBusy, isFalse);
    });

    test('restoreSession becomes authenticated when session exists', () async {
      final result = controller.restoreSession();

      expect(controller.state.status, AuthStatus.restoring);

      expect(controller.state.isBusy, isTrue);

      await result;

      expect(repository.restoreSessionCalled, isTrue);

      expect(controller.state.status, AuthStatus.authenticated);

      expect(controller.state.session, same(session));

      expect(controller.state.user, same(user));

      expect(controller.state.isAuthenticated, isTrue);

      expect(controller.state.isBusy, isFalse);
    });

    test(
      'restoreSession becomes unauthenticated when no session exists',
      () async {
        repository.restoreResult = null;

        await controller.restoreSession();

        expect(controller.state.status, AuthStatus.unauthenticated);

        expect(controller.state.session, isNull);

        expect(controller.state.isAuthenticated, isFalse);
      },
    );

    test('restoreSession becomes failure when repository throws', () async {
      repository.restoreError = Exception('network unavailable');

      await controller.restoreSession();

      expect(controller.state.status, AuthStatus.failure);

      expect(controller.state.session, isNull);

      expect(
        controller.state.errorMessage,
        'تعذر التحقق من جلسة المستخدم. حاول مرة أخرى.',
      );
    });

    test('login becomes authenticated and returns true on success', () async {
      final loginFuture = controller.login(
        login: '   test_user   ',
        password: 'secret123',
        deviceName: '   flutter-test   ',
      );

      expect(controller.state.status, AuthStatus.authenticating);

      expect(controller.state.isBusy, isTrue);

      final result = await loginFuture;

      expect(result, isTrue);

      expect(repository.loginCalled, isTrue);

      // AuthUseCase ينظف login وdeviceName.
      expect(repository.receivedLogin, 'test_user');

      expect(repository.receivedPassword, 'secret123');

      expect(repository.receivedDeviceName, 'flutter-test');

      expect(controller.state.status, AuthStatus.authenticated);

      expect(controller.state.session, same(session));

      expect(controller.state.isAuthenticated, isTrue);
    });

    test(
      'login becomes failure and returns false when repository throws',
      () async {
        repository.loginError = Exception('invalid credentials');

        final result = await controller.login(
          login: 'test_user',
          password: 'wrong-password',
          deviceName: 'flutter-test',
        );

        expect(result, isFalse);

        expect(controller.state.status, AuthStatus.failure);

        expect(controller.state.session, isNull);

        expect(
          controller.state.errorMessage,
          'تعذر تسجيل الدخول. تحقق من البيانات وحاول مرة أخرى.',
        );
      },
    );

    test('logout clears authenticated session on success', () async {
      await controller.login(
        login: 'test_user',
        password: 'secret123',
        deviceName: 'flutter-test',
      );

      expect(controller.state.isAuthenticated, isTrue);

      final logoutFuture = controller.logout();

      expect(controller.state.status, AuthStatus.signingOut);

      expect(controller.state.isBusy, isTrue);

      await logoutFuture;

      expect(repository.logoutCalled, isTrue);

      expect(controller.state.status, AuthStatus.unauthenticated);

      expect(controller.state.session, isNull);

      expect(controller.state.errorMessage, isNull);
    });

    test(
      'logout becomes unauthenticated even when remote logout fails',
      () async {
        await controller.login(
          login: 'test_user',
          password: 'secret123',
          deviceName: 'flutter-test',
        );

        repository.logoutError = Exception('network unavailable');

        await controller.logout();

        expect(repository.logoutCalled, isTrue);

        expect(controller.state.status, AuthStatus.unauthenticated);

        expect(controller.state.session, isNull);

        expect(
          controller.state.errorMessage,
          'تم تسجيل الخروج من الجهاز، لكن تعذر إنهاء الجلسة على الخادم.',
        );
      },
    );

    test('retryRestoreSession calls restoreSession again', () async {
      repository.restoreResult = null;

      await controller.restoreSession();

      expect(repository.restoreSessionCallCount, 1);

      repository.restoreResult = session;

      await controller.retryRestoreSession();

      expect(repository.restoreSessionCallCount, 2);

      expect(controller.state.status, AuthStatus.authenticated);

      expect(controller.state.session, same(session));
    });
  });
}

/// Fake Repository لاختبار AuthController بدون شبكة أو تخزين حقيقي.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.loginResult,
    required this.restoreResult,
    required this.currentUserResult,
  });

  AuthSessionEntity loginResult;
  AuthSessionEntity? restoreResult;
  AuthUserEntity currentUserResult;

  bool loginCalled = false;
  bool restoreSessionCalled = false;
  bool getCurrentUserCalled = false;
  bool logoutCalled = false;

  int restoreSessionCallCount = 0;

  String? receivedLogin;
  String? receivedPassword;
  String? receivedDeviceName;

  Object? loginError;
  Object? restoreError;
  Object? getCurrentUserError;
  Object? logoutError;

  Completer<AuthSessionEntity?>? restoreCompleter;

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

    final error = loginError;

    if (error != null) {
      throw error;
    }

    return loginResult;
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    restoreSessionCalled = true;
    restoreSessionCallCount++;

    final error = restoreError;

    if (error != null) {
      throw error;
    }

    final completer = restoreCompleter;

    if (completer != null) {
      return completer.future;
    }

    return restoreResult;
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    getCurrentUserCalled = true;

    final error = getCurrentUserError;

    if (error != null) {
      throw error;
    }

    return currentUserResult;
  }

  @override
  Future<void> logout() async {
    logoutCalled = true;

    final error = logoutError;

    if (error != null) {
      throw error;
    }
  }
}

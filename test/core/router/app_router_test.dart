/*
|--------------------------------------------------------------------------
| App Router Auth Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار تحويل المستخدم غير المسجل إلى Login.
| - اختبار تحويل المستخدم صاحب الجلسة الصالحة إلى MainPage.
| - اختبار البقاء في AuthSessionPage عند فشل استعادة الجلسة.
| - اختبار الانتقال من Login إلى MainPage بعد نجاح تسجيل الدخول.
|
| الهدف:
| إثبات أن GoRouter يتفاعل فعليًا مع AuthController
| دون استخدام Laravel أو Secure Storage أو HTTP.
|
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/router/app_router.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/presentation/pages/auth_session_page.dart';
import 'package:talbatiyk/features/auth/presentation/pages/login_page.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/navigation/presentation/pages/main_page.dart';

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
  Future<void> pumpRouterFrames(WidgetTester tester) async {
    /*
   * نعطي GoRouter وقتًا لتنفيذ redirect
   * وإنهاء انتقال الصفحة بالكامل.
   *
   * لا نستخدم pumpAndSettle لأن MainPage قد تستمر
   * في جدولة Frames بسبب الصور والـProviders.
   */
    await tester.pump();

    for (var index = 0; index < 12; index++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<ProviderContainer> pumpRouter({
    required WidgetTester tester,
    required FakeAuthRepository repository,
  }) async {
    final container = ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
    );

    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    /*
     * ننتظر انتهاء restoreSession وRedirect الناتج عنه.
     */
    await pumpRouterFrames(tester);
    return container;
  }

  group('App Router Auth Guard', () {
    testWidgets('redirects unauthenticated user to LoginPage', (tester) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );

      await pumpRouter(tester: tester, repository: repository);

      expect(find.byType(LoginPage), findsOneWidget);

      expect(find.byType(MainPage), findsNothing);
    });

    testWidgets('redirects authenticated user to MainPage', (tester) async {
      final repository = FakeAuthRepository(
        restoreResult: session,
        loginResult: session,
        currentUserResult: user,
      );

      await pumpRouter(tester: tester, repository: repository);

      expect(find.byType(MainPage), findsOneWidget);

      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('keeps user on AuthSessionPage when restore fails', (
      tester,
    ) async {
      final repository = FakeAuthRepository(
        restoreResult: session,
        loginResult: session,
        currentUserResult: user,
      );

      repository.restoreError = Exception('network unavailable');

      await pumpRouter(tester: tester, repository: repository);

      expect(find.byType(AuthSessionPage), findsOneWidget);

      expect(find.text('إعادة المحاولة'), findsOneWidget);

      expect(find.byType(LoginPage), findsNothing);

      expect(find.byType(MainPage), findsNothing);
    });

    testWidgets('redirects from LoginPage to MainPage after successful login', (
      tester,
    ) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );

      final container = await pumpRouter(
        tester: tester,
        repository: repository,
      );

      // بعد restoreSession بدون Token نكون في Login.
      expect(find.byType(LoginPage), findsOneWidget);

      final result = await container
          .read(authProvider)
          .login(
            login: 'test_user',
            password: 'secret123',
            deviceName: 'flutter-test',
          );

      expect(result, isTrue);

      /*
         * AuthController استدعى notifyListeners،
         * ولذلك GoRouter سيعيد تقييم redirect.
         */
      await pumpRouterFrames(tester);

      expect(find.byType(MainPage), findsOneWidget);

      expect(find.byType(LoginPage), findsNothing);
    });
  });
}

/// Repository وهمي لاختبار Router وحالة Auth فقط.
final class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({
    required this.restoreResult,
    required this.loginResult,
    required this.currentUserResult,
  });

  AuthSessionEntity? restoreResult;
  AuthSessionEntity loginResult;
  AuthUserEntity currentUserResult;

  Object? restoreError;
  Object? loginError;
  Object? logoutError;

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    final error = restoreError;

    if (error != null) {
      throw error;
    }

    return restoreResult;
  }

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    final error = loginError;

    if (error != null) {
      throw error;
    }

    return loginResult;
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    return currentUserResult;
  }

  @override
  Future<void> logout() async {
    final error = logoutError;

    if (error != null) {
      throw error;
    }
  }
}

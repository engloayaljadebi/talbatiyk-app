/*
|--------------------------------------------------------------------------
| App Router Auth Tests
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - اختبار أن Production Main Route يستخدم MainPage افتراضيًا.
| - اختبار تحويل المستخدم غير المسجل إلى Login.
| - اختبار تحويل المستخدم صاحب الجلسة الصالحة إلى Main route.
| - اختبار البقاء في AuthSessionPage عند فشل استعادة الجلسة.
| - اختبار الانتقال من Login إلى Main route بعد نجاح تسجيل الدخول.
|
| الهدف:
| إثبات أن GoRouter يتفاعل فعليًا مع AuthController
| دون استخدام Laravel أو Secure Storage أو HTTP
| ودون بناء MainPage الحقيقية داخل اختبارات Router.
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
     * نعطي GoRouter وقتًا لتنفيذ Redirect
     * واستقرار انتقال الصفحة.
     *
     * نستخدم Pumps محددة حتى يبقى الاختبار
     * متحكمًا في عدد Frames ولا يعتمد على Timers مستقبلية.
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
      overrides: [
        /*
         * نعزل AuthRepository الحقيقي.
         *
         * اختبار Router لا يحتاج Laravel
         * أو HTTP أو Secure Storage.
         */
        authRepositoryProvider.overrideWithValue(repository),

        /*
         * اختبار Router يهتم فقط بالوصول
         * إلى المسار الرئيسي.
         *
         * لذلك لا نبني MainPage الحقيقية
         * ولا Home ولا Products ولا Network Images.
         */
        mainRoutePageFactoryProvider.overrideWithValue(
          () => const _TestMainPage(),
        ),
      ],
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
     * ننتظر انتهاء restoreSession
     * والـRedirect الناتج عنه.
     */
    await pumpRouterFrames(tester);

    return container;
  }

  test('main route factory uses MainPage by default', () {
    final container = ProviderContainer();

    addTearDown(container.dispose);

    final page = container.read(mainRoutePageFactoryProvider)();

    expect(page, isA<MainPage>());
  });

  group('App Router Auth Guard', () {
    testWidgets('redirects unauthenticated user to LoginPage', (tester) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );

      await pumpRouter(tester: tester, repository: repository);

      expect(find.byType(LoginPage), findsOneWidget);

      expect(find.byType(_TestMainPage), findsNothing);
    });

    testWidgets('redirects authenticated user to MainPage', (tester) async {
      final repository = FakeAuthRepository(
        restoreResult: session,
        loginResult: session,
        currentUserResult: user,
      );

      await pumpRouter(tester: tester, repository: repository);

      expect(find.byType(_TestMainPage), findsOneWidget);

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

      expect(find.byType(_TestMainPage), findsNothing);
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

      /*
         * بعد restoreSession بدون Session
         * يجب أن نكون في LoginPage.
         */
      expect(find.byType(LoginPage), findsOneWidget);

      expect(find.byType(_TestMainPage), findsNothing);

      final result = await container
          .read(authProvider)
          .login(
            login: 'test_user',
            password: 'secret123',
            deviceName: 'flutter-test',
          );

      expect(result, isTrue);

      /*
         * AuthController غيّر حالة المصادقة،
         * ولذلك GoRouter سيعيد تقييم Redirect.
         */
      await pumpRouterFrames(tester);

      expect(find.byType(_TestMainPage), findsOneWidget);

      expect(find.byType(LoginPage), findsNothing);
    });
  });
}

/// صفحة خفيفة تمثل الوجهة الرئيسية داخل اختبارات Router فقط.
///
/// وجود صفحة مستقلة يسمح لنا بالتأكد من نجاح Redirect
/// بدون بناء MainPage الحقيقية وتشغيل Features غير مرتبطة بالاختبار.
final class _TestMainPage extends StatelessWidget {
  const _TestMainPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: Text('test-main-page')));
  }
}

/// Repository وهمي لاختبار Router وحالة Auth فقط.
///
/// لا يستخدم:
/// - Laravel
/// - HTTP
/// - Secure Storage
/// - قاعدة البيانات الحقيقية
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

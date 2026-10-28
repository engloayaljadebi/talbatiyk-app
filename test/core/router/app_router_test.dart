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
import 'package:talbatiyk/core/router/route_names.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/presentation/pages/auth_session_page.dart';
import 'package:talbatiyk/features/auth/presentation/pages/login_page.dart';
import 'package:talbatiyk/features/auth/presentation/pages/register_page.dart';
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
    testWidgets('guest can open existing RegisterPage from login', (
      tester,
    ) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );

      await pumpRouter(tester: tester, repository: repository);
      expect(find.byType(LoginPage), findsOneWidget);

      final link = find.text('إنشاء حساب جديد');
      expect(link, findsOneWidget);
      await tester.tap(link);
      await pumpRouterFrames(tester);

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
    });

    testWidgets('registration link works after login failure', (tester) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );
      repository.loginError = StateError('invalid login');

      final container = await pumpRouter(
        tester: tester,
        repository: repository,
      );
      final success = await container
          .read(authProvider)
          .login(
            login: 'invalid_user',
            password: 'wrong',
            deviceName: 'flutter-test',
          );
      expect(success, isFalse);
      await pumpRouterFrames(tester);

      final link = find.text('إنشاء حساب جديد');
      await tester.ensureVisible(link);
      await tester.tap(link);
      await pumpRouterFrames(tester);

      expect(find.byType(RegisterPage), findsOneWidget);
    });

    testWidgets('authenticated user cannot open registration route', (
      tester,
    ) async {
      final repository = FakeAuthRepository(
        restoreResult: session,
        loginResult: session,
        currentUserResult: user,
      );

      final container = await pumpRouter(
        tester: tester,
        repository: repository,
      );
      container.read(appRouterProvider).go(RouteNames.register);
      await pumpRouterFrames(tester);

      expect(find.byType(_TestMainPage), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    });

    testWidgets('registration success redirects to main route', (tester) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );

      final container = await pumpRouter(
        tester: tester,
        repository: repository,
      );
      container.read(appRouterProvider).go(RouteNames.register);
      await pumpRouterFrames(tester);
      expect(find.byType(RegisterPage), findsOneWidget);

      final success = await container.read(authProvider).registerFromMobile({
        'account_type': 'shop',
      });
      expect(success, isTrue);
      await pumpRouterFrames(tester);

      expect(find.byType(_TestMainPage), findsOneWidget);
      expect(find.byType(RegisterPage), findsNothing);
    });

    testWidgets('registration failure remains on registration route', (
      tester,
    ) async {
      final repository = FakeAuthRepository(
        restoreResult: null,
        loginResult: session,
        currentUserResult: user,
      );
      repository.registrationError = StateError('test failure');

      final container = await pumpRouter(
        tester: tester,
        repository: repository,
      );
      container.read(appRouterProvider).go(RouteNames.register);
      await pumpRouterFrames(tester);
      expect(find.byType(RegisterPage), findsOneWidget);

      final success = await container.read(authProvider).registerFromMobile({
        'account_type': 'supplier',
      });
      expect(success, isFalse);
      await pumpRouterFrames(tester);

      expect(find.byType(RegisterPage), findsOneWidget);
      expect(find.byType(LoginPage), findsNothing);
      expect(
        container.read(authProvider).state.registrationErrorMessage,
        'تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.',
      );

      await tester.scrollUntilVisible(
        find.text('تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.'),
        250,
        scrollable: find
            .descendant(
              of: find.byType(RegisterPage),
              matching: find.byType(Scrollable),
            )
            .first,
        maxScrolls: 40,
      );

      expect(
        find.text('تعذر إنشاء الحساب. تحقق من البيانات وحاول مرة أخرى.'),
        findsOneWidget,
      );
    });
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
  @override
  Future<List<({String id, String name})>> fetchRegistrationCategories() async {
    return [(id: '11111111-1111-4111-8111-111111111111', name: 'فئة تجريبية')];
  }

  @override
  Future<AuthSessionEntity> registerFromMobile(
    Map<String, Object?> payload,
  ) async {
    final error = registrationError;
    if (error != null) {
      throw error;
    }
    return loginResult;
  }

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
  Object? registrationError;
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
  Future<AuthUserEntity> updateProfile({
    String? username,
    String? displayName,
  }) async {
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

/*
|--------------------------------------------------------------------------
| App Router
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - إنشاء GoRouter الرئيسي للتطبيق.
| - حماية المسارات حسب حالة المصادقة.
| - إعادة تقييم Redirect عند تغير AuthController.
| - توجيه المستخدم إلى Auth / Login / Main.
|
| التدفق:
|
| initial/restoring
|       ↓
|     /auth
|
| unauthenticated
|       ↓
|    /login
|
| authenticated
|       ↓
|       /
|
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/auth_session_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/states/auth_state.dart';
import '../../features/navigation/presentation/pages/main_page.dart';
import 'route_names.dart';

/// Factory لصفحة المسار الرئيسي.
///
/// Production يستخدم MainPage الفعلية، بينما اختبارات Router
/// تستطيع استبدالها بصفحة خفيفة حتى لا تشغّل Features غير مرتبطة
/// باختبار التوجيه مثل Products وNetwork Images.
typedef MainRoutePageFactory = Widget Function();

final mainRoutePageFactoryProvider = Provider<MainRoutePageFactory>(
  (ref) =>
      () => const MainPage(),
);

/// يوفر Router واحدًا مرتبطًا بحالة المصادقة.
final appRouterProvider = Provider<GoRouter>((ref) {
  final authController = ref.read(authProvider);

  final router = GoRouter(
    initialLocation: RouteNames.auth,

    /*
     * AuthController هو ChangeNotifier.
     *
     * كل notifyListeners() يعيد تقييم redirect
     * دون الحاجة إلى إنشاء Router جديد.
     */
    refreshListenable: authController,

    redirect: (context, state) {
      final status = authController.state.status;
      final currentPath = state.uri.path;

      final isAuthPage = currentPath == RouteNames.auth;
      final isLoginPage = currentPath == RouteNames.login;

      switch (status) {
        case AuthStatus.initial:
        case AuthStatus.restoring:
          if (isAuthPage) {
            return null;
          }

          return RouteNames.auth;

        case AuthStatus.unauthenticated:
          if (isLoginPage) {
            return null;
          }

          return RouteNames.login;

        case AuthStatus.authenticating:
          if (isLoginPage) {
            return null;
          }

          return RouteNames.login;

        case AuthStatus.authenticated:
          if (isAuthPage || isLoginPage) {
            return RouteNames.main;
          }

          return null;

        case AuthStatus.signingOut:
          /*
           * نبقى في الصفحة الحالية حتى ينتهي Repository
           * من تنظيف الجلسة المحلية.
           *
           * بعدها تصبح الحالة unauthenticated
           * وينقلنا Router إلى Login.
           */
          return null;

        case AuthStatus.failure:
          /*
           * إذا حدث الخطأ أثناء Login نبقى في Login
           * لعرض رسالة الخطأ.
           *
           * وإذا حدث أثناء restoreSession نبقى في
           * AuthSessionPage لعرض زر إعادة المحاولة.
           */
          if (isLoginPage || isAuthPage) {
            return null;
          }

          return RouteNames.auth;
      }
    },

    routes: [
      GoRoute(
        path: RouteNames.auth,
        builder: (context, state) {
          return const AuthSessionPage();
        },
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) {
          return const LoginPage();
        },
      ),
      GoRoute(
        path: RouteNames.main,
        builder: (context, state) {
          // نعزل إنشاء الصفحة عن منطق Router حتى تبقى اختبارات
          // Auth Guard مستقلة عن Features الموجودة داخل MainPage.
          return ref.read(mainRoutePageFactoryProvider)();
        },
      ),
    ],
  );

  ref.onDispose(router.dispose);

  return router;
});

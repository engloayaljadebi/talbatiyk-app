// محتوى الملف:
// - إنشاء Router الرئيسي للتطبيق.
// - تحديد أول صفحة تظهر عند التشغيل.
// - تسجيل مسارات التطبيق المركزية.
//
// MainPage تدير حاليًا:
// - الرئيسية.
// - المنتجات.
// - السلة.
// - الطلبات.
// - الحساب.

import 'package:go_router/go_router.dart';

import '../../features/navigation/presentation/pages/main_page.dart';
import 'route_names.dart';

/// نظام التنقل الرئيسي لتطبيق طلبيتك.
final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.main,
  routes: [
    GoRoute(
      path: RouteNames.main,
      builder: (context, state) => const MainPage(),
    ),
  ],
);

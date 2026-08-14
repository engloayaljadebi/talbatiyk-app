/*
|--------------------------------------------------------------------------
| Talbatiyk App
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تعريف الواجهة العليا لتطبيق طلبيتك.
| - تشغيل نظام المصادقة عند بداية التطبيق.
| - تطبيق الثيم العام.
| - فرض اتجاه RTL.
| - ربط التطبيق بنظام GoRouter.
|
| ملاحظة:
| في هذه المرحلة نبدأ استعادة جلسة المستخدم فقط.
| ربط AuthStatus بالمسارات وشاشة تسجيل الدخول سيتم في الخطوة التالية.
|
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// الواجهة العليا والرئيسية لتطبيق طلبيتك.
class TalbatiykApp extends ConsumerWidget {
  const TalbatiykApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /*
     * مجرد الاستماع إلى authProvider يؤدي إلى إنشائه.
     *
     * AuthController يبدأ restoreSession() تلقائيًا،
     * وبالتالي يتم فحص الجلسة المحفوظة عند تشغيل التطبيق.
     */

    return MaterialApp.router(
      title: 'طلبيتك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: ref.watch(appRouterProvider),

      // يفرض اتجاه RTL على جميع واجهات التطبيق.
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

// محتوى الملف:
// - تعريف الواجهة العليا لتطبيق طلبيتك.
// - تطبيق الثيم العام.
// - فرض اتجاه الواجهات من اليمين إلى اليسار.
// - ربط التطبيق بنظام التنقل GoRouter.

import 'package:flutter/material.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// الواجهة العليا والرئيسية لتطبيق طلبيتك.
class TalbatiykApp extends StatelessWidget {
  const TalbatiykApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'طلبيتك',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,

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

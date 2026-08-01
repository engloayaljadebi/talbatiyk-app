import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/home/presentation/pages/home_page.dart';

void main() {
  runApp(const TalbatiykApp());
}

class TalbatiykApp extends StatelessWidget {
  const TalbatiykApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'طلبيتك',

      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,

      // جعل التطبيق بالكامل من اليمين إلى اليسار
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const HomePage(),
    );
  }
}

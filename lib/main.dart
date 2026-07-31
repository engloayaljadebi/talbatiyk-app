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
      home: const HomePage(),
    );
  }
}
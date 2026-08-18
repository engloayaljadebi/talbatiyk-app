import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// File: home_page.dart
///
/// المسؤولية:
/// - تركيب محتوى الصفحة الرئيسية.
/// - عرض الأقسام التي لها سلوك فعلي في المرحلة الحالية.
///
/// لا يحتوي:
/// - Business logic.
/// - Mock product/category data.
/// - Network calls مباشرة.
/// ---------------------------------------------------------------------------
class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onViewProducts});

  final VoidCallback onViewProducts;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,

        // لا نظهر Actions غير منفذة في المرحلة الحالية.
        // ستضاف الإشعارات والحساب عندما تصبح لها Navigation فعلية.
        title: const Text(
          'طلبيتك',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

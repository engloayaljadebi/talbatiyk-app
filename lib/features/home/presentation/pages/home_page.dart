import 'package:flutter/material.dart';
import 'package:talbatiyk/features/home/presentation/widgets/widgets.dart';

/// ---------------------------------------------------------------------------
/// File: home_page.dart
///
/// المسؤولية:
/// - تركيب محتوى الصفحة الرئيسية.
/// - عرض الأقسام التي تعتمد على بيانات فعلية في المرحلة الحالية.
///
/// لا يحتوي:
/// - Mock product/category data.
/// - Network calls مباشرة.
/// - Business logic.
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
        title: const Text(
          'طلبيتك',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: BannerSlider()),
            SliverToBoxAdapter(
              child: LatestProductsSection(onViewAll: onViewProducts),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }
}

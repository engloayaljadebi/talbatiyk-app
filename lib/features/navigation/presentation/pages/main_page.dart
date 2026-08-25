// محتوى الملف:
// - إدارة أقسام التطبيق الخمسة.
// - التنقل بين الرئيسية والمنتجات والسلة والطلبات والحساب.
// - الاحتفاظ بحالة كل صفحة باستخدام IndexedStack.
// - عرض شريط التنقل السفلي بشكل عائم.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../account/presentation/pages/account_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../widgets/home_bottom_navigation.dart';

/// الصفحة الأساسية التي تحتوي على أقسام التطبيق الخمسة.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  /// رقم القسم المحدد حاليًا.
  int _currentIndex = 0;

  /// صفحات التطبيق.
  ///
  /// يجب أن يتطابق ترتيب الصفحات مع ترتيب عناصر
  /// شريط التنقل السفلي.
  late final List<Widget> _pages = [
    HomePage(
      // ينقل المستخدم إلى قسم المنتجات.
      onViewProducts: () => _changePage(1),
    ),
    ProductsPage(),
    const CartPage(),
    const OrdersPage(),
    AccountPage(
      onLogout: () async {
        await ref.read(authProvider).logout();
      },
    ),
  ];

  /// ينتقل إلى القسم المطلوب.
  ///
  /// يمنع إعادة بناء الواجهة إذا ضغط المستخدم
  /// على القسم المفتوح حاليًا.
  void _changePage(int index) {
    if (_currentIndex == index) {
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // مساحة شريط النظام أسفل شاشة الهاتف.
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      // يسمح لشريط التنقل بالظهور عائمًا فوق محتوى الصفحات.
      extendBody: false,
      body: Stack(
        children: [
          // يحتفظ بحالة الصفحات عند التنقل بينها.
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),

          // شريط التنقل السفلي العائم.
          Positioned(
            left: 15,
            right: 15,
            bottom: bottomInset + 8,
            child: HomeBottomNavigation(
              currentIndex: _currentIndex,
              onDestinationSelected: _changePage,
            ),
          ),
        ],
      ),
    );
  }
}

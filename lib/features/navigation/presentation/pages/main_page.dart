import 'package:flutter/material.dart';
import 'package:talbatiyk/features/navigation/presentation/widgets/home_bottom_navigation.dart';

import '../../../cart/presentation/pages/cart_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../products/presentation/pages/products_page.dart';

/// الصفحة الأساسية التي تحتوي على أقسام التطبيق.
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  /// رقم الصفحة المحددة حاليًا.
  int _currentIndex = 0;

  /// صفحات التطبيق، ويجب أن يتطابق ترتيبها مع عناصر الشريط.
  late final List<Widget> _pages = [
    HomePage(onViewProducts: () => _changePage(1)),
    ProductsPage(),
    const CartPage(),
    const OrdersPage(),
    const _TemporaryPage(title: 'حسابي'),
  ];

  /// تغيير الصفحة الحالية.
  void _changePage(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      // يسمح للشريط بالظهور عائمًا فوق محتوى الصفحات.
      extendBody: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: IndexedStack(index: _currentIndex, children: _pages),
          ),

          /// تحديد موقع الشريط وعرضه من هذا الملف فقط.
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

/// صفحة مؤقتة للسلة والحساب.
class _TemporaryPage extends StatelessWidget {
  const _TemporaryPage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(
          '$title قيد التطوير',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}

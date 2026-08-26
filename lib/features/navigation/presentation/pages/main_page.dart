import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../account/presentation/pages/account_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../widgets/home_bottom_navigation.dart';

/// الصفحة الأساسية التي تحتوي على أقسام التطبيق الخمسة.
class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage>
    with WidgetsBindingObserver {
  /// رقم القسم المحدد حاليًا.
  int _currentIndex = 0;

  /// يمنع تشغيل أكثر من مزامنة للطلبات في الوقت نفسه.
  bool _isSyncingOrders = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // نبدأ المزامنة بعد بناء الـ authenticated shell لأول مرة.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncPendingOrders());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncPendingOrders());
    }
  }

  /// يرسل الطلبات الموجودة في Outbox إلى الخادم،
  /// ثم يعيد تحميل الطلبات المحلية بعد reconciliation.
  Future<void> _syncPendingOrders() async {
    if (_isSyncingOrders) {
      return;
    }

    _isSyncingOrders = true;

    // نقرأ الاعتمادات قبل await حتى لا نستخدم ref
    // بعد التخلص من الصفحة.
    final syncCoordinator = ref.read(ordersSyncCoordinatorProvider);

    final ordersController = ref.read(ordersProvider);

    try {
      await syncCoordinator.syncPendingOrders();

      if (!mounted) {
        return;
      }

      // يعيد تحميل Local source بعد reconciliation حتى تختفي
      // local-order-* وتظهر نسخة السيرفر مباشرة في Orders UI.
      await ordersController.loadOrders();
    } catch (error, stackTrace) {
      // المزامنة الخلفية يجب ألا تكسر الـShell الرئيسي.
      debugPrint('Orders background sync failed: $error\n$stackTrace');
    } finally {
      _isSyncingOrders = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

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
    return Scaffold(
      // يحتفظ IndexedStack بحالة كل قسم
      // عند التنقل بين صفحات التطبيق.
      body: IndexedStack(index: _currentIndex, children: _pages),

      // يملك الـShell الرئيسي شريط التنقل حتى يحجز Scaffold مساحته
      // ولا يُرسم فوق محتوى الصفحات مثل Checkout في CartPage.
      bottomNavigationBar: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(15, 0, 15, 8),
        child: HomeBottomNavigation(
          currentIndex: _currentIndex,
          onDestinationSelected: _changePage,
        ),
      ),
    );
  }
}

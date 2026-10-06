import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/route_names.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../business/presentation/providers/business_provider.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../received_orders/presentation/providers/received_orders_provider.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../orders/presentation/pages/orders_page.dart';
import '../../../orders/presentation/providers/orders_provider.dart';
import '../../../products/presentation/pages/products_page.dart';
import '../../../products/presentation/providers/products_provider.dart';
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

  bool _isSyncingProducts = false;

  bool _isRefreshingReceivedOrders = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    // نبدأ المزامنة بعد بناء الـ authenticated shell لأول مرة.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_syncPendingOrders());
      unawaited(_syncPendingProducts());
      unawaited(_refreshReceivedOrders());
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_syncPendingOrders());
      unawaited(_syncPendingProducts());
      unawaited(_refreshReceivedOrders());
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

  Future<void> _syncPendingProducts() async {
    if (_isSyncingProducts) {
      return;
    }

    _isSyncingProducts = true;

    final syncCoordinator = ref.read(productsSyncCoordinatorProvider);
    final productsController = ref.read(productsProvider);

    try {
      await syncCoordinator.syncPendingProducts();

      if (!mounted) {
        return;
      }

      await productsController.loadProducts();
    } catch (error, stackTrace) {
      debugPrint('Products background sync failed: $error\n$stackTrace');
    } finally {
      _isSyncingProducts = false;
    }
  }

  Future<void> _refreshReceivedOrders() async {
    if (_isRefreshingReceivedOrders) {
      return;
    }

    _isRefreshingReceivedOrders = true;

    try {
      final businessController = ref.read(businessControllerProvider);

      if (businessController.state.businesses.isEmpty &&
          !businessController.state.isLoading) {
        await businessController.loadBusinesses();
      }

      if (!mounted) {
        return;
      }

      final businesses = businessController.state.businesses;

      await Future.wait(
        businesses.map(
          (business) => ref
              .read(receivedOrdersControllerProvider(business.id))
              .loadReceivedOrders(),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint(
        'Received orders background refresh failed: '
        '$error\n$stackTrace',
      );
    } finally {
      _isRefreshingReceivedOrders = false;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  /// يفتح Route الإشعارات للمستخدم المصادق عليه.
  ///
  /// MainPage يملك قرار التنقل حتى تبقى Home مستقلة عن GoRouter.
  void _openNotifications() {
    unawaited(GoRouter.of(context).push<void>(RouteNames.notifications));
  }

  /// صفحات التطبيق.  ///
  /// يجب أن يتطابق ترتيب الصفحات مع ترتيب عناصر
  /// شريط التنقل السفلي.
  late final List<Widget> _pages = [
    HomePage(
      // Home لا تعرف أرقام Tabs أو GoRouter؛ الـShell يمرر الإجراءات فقط.
      onViewProducts: () => _changePage(1),
      onOpenCart: () => _changePage(2),
      onOpenAccount: () => _changePage(4),
      onOpenNotifications: _openNotifications,
    ),
    ProductsPage(),
    const CartPage(),
    const OrdersPage(),
    AccountPage(
      onOpenNotifications: _openNotifications,
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
      if (index == 3) {
        unawaited(_refreshReceivedOrders());
      }

      return;
    }

    setState(() {
      _currentIndex = index;
    });

    if (index == 3) {
      unawaited(_refreshReceivedOrders());
    }
  }

  @override
  Widget build(BuildContext context) {
    final businessController = ref.watch(businessControllerProvider);

    var ordersActionCount = 0;

    for (final business in businessController.state.businesses) {
      final receivedController = ref.watch(
        receivedOrdersControllerProvider(business.id),
      );

      ordersActionCount += receivedController.state.orders
          .where(
            (order) =>
                !order.hasResponse ||
                (order.hasSelection && order.nextFulfillmentStatus != null),
          )
          .length;
    }

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
          ordersBadgeCount: ordersActionCount,
          onDestinationSelected: _changePage,
        ),
      ),
    );
  }
}

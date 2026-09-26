import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../notifications/presentation/providers/notifications_provider.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../widgets/widgets.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({
    super.key,
    required this.onViewProducts,
    required this.onOpenCart,
    required this.onOpenNotifications,
    this.onOpenAccount,
  });

  final VoidCallback onViewProducts;
  final VoidCallback onOpenCart;
  final VoidCallback onOpenNotifications;
  final VoidCallback? onOpenAccount;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  String? _loadedNotificationsUserId;
  String? _scheduledNotificationsUserId;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).state.user;
    final userId = user?.id.trim() ?? '';

    final cartQuantity = ref.watch(
      cartProvider.select((cart) => cart.totalQuantity),
    );

    final productsController = ref.watch(productDiscoveryProvider);
    final categories = productsController.categories;
    final selectedCategory = productsController.state.selectedCategory;

    var unreadNotifications = 0;

    if (userId.isNotEmpty) {
      final notificationsController = ref.watch(notificationsProvider(userId));

      unreadNotifications = notificationsController.state.unreadCount;
      _ensureNotificationsLoaded(userId);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        toolbarHeight: 56,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: const Text(
          'طلبيتك',
          style: TextStyle(
            color: Color(0xFF181818),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: PopupMenuButton<_HomeMenuAction>(
          key: const ValueKey<String>('home-menu-action'),
          tooltip: 'القائمة',
          icon: const Icon(
            Icons.menu_rounded,
            color: Color(0xFF181818),
            size: 24,
          ),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _HomeMenuAction.products,
              child: Text('المنتجات'),
            ),
            PopupMenuItem(value: _HomeMenuAction.cart, child: Text('السلة')),
            PopupMenuItem(
              value: _HomeMenuAction.account,
              child: Text('الحساب'),
            ),
          ],
        ),
        actions: [
          _HomeTopAction(
            key: const ValueKey<String>('home-notifications-action'),
            icon: Icons.notifications_none_rounded,
            tooltip: 'الإشعارات',
            count: unreadNotifications,
            onPressed: userId.isEmpty ? null : widget.onOpenNotifications,
          ),
          _HomeTopAction(
            key: const ValueKey<String>('home-account-action'),
            icon: Icons.person_outline_rounded,
            tooltip: 'الحساب',
            count: 0,
            onPressed: widget.onOpenAccount,
          ),
          const SizedBox(width: 5),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _HomeSearchBar(
                controller: _searchController,
                onSubmitted: _submitProductSearch,
                onOpenFilters: widget.onViewProducts,
              ),
            ),
            SliverToBoxAdapter(
              child: BannerSlider(onExploreProducts: widget.onViewProducts),
            ),
            if (categories.isNotEmpty)
              SliverToBoxAdapter(
                child: _HomeCategoriesSection(
                  categories: categories,
                  selectedCategory: selectedCategory,
                  onSelected: _openCategory,
                ),
              ),
            SliverToBoxAdapter(
              child: LatestProductsSection(onViewAll: widget.onViewProducts),
            ),
            SliverToBoxAdapter(
              child: _HomeCartStrip(
                quantity: cartQuantity,
                onPressed: widget.onOpenCart,
              ),
            ),
            const SliverPadding(padding: EdgeInsets.only(bottom: 14)),
          ],
        ),
      ),
    );
  }

  void _submitProductSearch(String value) {
    final query = value.trim();

    ref.read(productDiscoveryProvider).search(query);
    widget.onViewProducts();
  }

  void _openCategory(String category) {
    final controller = ref.read(productDiscoveryProvider);

    _searchController.clear();
    controller.clearAll();

    controller.applyFilters(
      category: category,
      brand: '',
      availability: controller.state.availability,
      minPrice: controller.minimumPrice,
      maxPrice: controller.maximumPrice,
    );

    widget.onViewProducts();
  }

  void _handleMenuAction(_HomeMenuAction action) {
    switch (action) {
      case _HomeMenuAction.products:
        widget.onViewProducts();
      case _HomeMenuAction.cart:
        widget.onOpenCart();
      case _HomeMenuAction.account:
        widget.onOpenAccount?.call();
    }
  }

  void _ensureNotificationsLoaded(String userId) {
    if (_loadedNotificationsUserId == userId ||
        _scheduledNotificationsUserId == userId) {
      return;
    }

    _scheduledNotificationsUserId = userId;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _scheduledNotificationsUserId != userId) {
        return;
      }

      _scheduledNotificationsUserId = null;
      _loadedNotificationsUserId = userId;

      unawaited(ref.read(notificationsProvider(userId)).load());
    });
  }
}

enum _HomeMenuAction { products, cart, account }

class _HomeSearchBar extends StatelessWidget {
  const _HomeSearchBar({
    required this.controller,
    required this.onSubmitted,
    required this.onOpenFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 6),
      padding: const EdgeInsetsDirectional.only(start: 13, end: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF202124), size: 23),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              key: const ValueKey<String>('home-product-search'),
              controller: controller,
              textInputAction: TextInputAction.search,
              textAlign: TextAlign.start,
              onSubmitted: onSubmitted,
              decoration: const InputDecoration(
                hintText: 'ابحث عن منتج أو شركة...',
                hintStyle: TextStyle(color: Color(0xFFB7B7B7), fontSize: 12),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.mic_none_rounded,
              size: 21,
              color: Color(0xFF898989),
            ),
          ),
          SizedBox(
            width: 39,
            height: 39,
            child: Material(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: onOpenFilters,
                borderRadius: BorderRadius.circular(12),
                child: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeCategoriesSection extends StatelessWidget {
  const _HomeCategoriesSection({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 18, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'الأقسام',
            textAlign: TextAlign.start,
            style: TextStyle(
              color: Color(0xFF1D1D1D),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 13),
          SizedBox(
            height: 88,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final category = categories[index];

                return _HomeCategoryItem(
                  key: ValueKey<String>('home-category-$category'),
                  label: category,
                  icon: _iconForCategory(category),
                  selected: selectedCategory == category,
                  onTap: () => onSelected(category),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconForCategory(String category) {
    final value = category.trim().toLowerCase();

    if (value.contains('هاتف') ||
        value.contains('جوال') ||
        value.contains('phone') ||
        value.contains('mobile')) {
      return Icons.smartphone_rounded;
    }

    if (value.contains('سماع') ||
        value.contains('headphone') ||
        value.contains('audio')) {
      return Icons.headphones_rounded;
    }

    if (value.contains('شاحن') ||
        value.contains('كابل') ||
        value.contains('charger') ||
        value.contains('cable')) {
      return Icons.electrical_services_rounded;
    }

    if (value.contains('اكسسوار') ||
        value.contains('إكسسوار') ||
        value.contains('accessor')) {
      return Icons.devices_other_rounded;
    }

    return Icons.category_outlined;
  }
}

class _HomeCategoryItem extends StatelessWidget {
  const _HomeCategoryItem({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 68,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.16)
                    : AppColors.primary.withValues(alpha: 0.08),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Icon(icon, size: 23, color: AppColors.primary),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                height: 1.15,
                color: selected ? AppColors.primary : const Color(0xFF393939),
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeCartStrip extends StatelessWidget {
  const _HomeCartStrip({required this.quantity, required this.onPressed});

  final int quantity;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 2),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        child: InkWell(
          key: const ValueKey<String>('home-cart-action'),
          onTap: onPressed,
          borderRadius: BorderRadius.circular(17),
          child: SizedBox(
            height: 58,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primary,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'سلة التسوق',
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Color(0xFF1C1C1C),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (quantity > 0)
                    Container(
                      constraints: const BoxConstraints(
                        minWidth: 27,
                        minHeight: 27,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 7),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        quantity > 99 ? '99+' : '$quantity',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeTopAction extends StatelessWidget {
  const _HomeTopAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.count,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final int count;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: SizedBox(
        width: 30,
        height: 30,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(
              child: Icon(
                icon,
                size: 21,
                color: onPressed == null
                    ? const Color(0xFFB5B5B5)
                    : const Color(0xFF7D7D7D),
              ),
            ),
            if (count > 0)
              PositionedDirectional(
                top: -3,
                end: -4,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                  child: Text(
                    count > 99 ? '99+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      height: 1,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      height: 72,
      elevation: 6,
      backgroundColor: Colors.white,
      indicatorColor: AppColors.primary.withOpacity(.12),
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.home_rounded),
          icon: Icon(Icons.home_outlined),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_2_rounded),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'المنتجات',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.shopping_cart_rounded),
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'السلة',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.receipt_long_rounded),
          icon: Icon(Icons.receipt_long_outlined),
          label: 'الطلبات',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person_rounded),
          icon: Icon(Icons.person_outline),
          label: 'الحساب',
        ),
      ],
    );
  }
}
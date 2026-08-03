import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(Icons.home),
          icon: Icon(Icons.home_outlined),
          label: 'الرئيسية',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.inventory_2),
          icon: Icon(Icons.inventory_2_outlined),
          label: 'المنتجات',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.shopping_cart),
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'السلة',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.receipt_long),
          icon: Icon(Icons.receipt_long_outlined),
          label: 'طلباتي',
        ),
        NavigationDestination(
          selectedIcon: Icon(Icons.person),
          icon: Icon(Icons.person_outline),
          label: 'حسابي',
        ),
      ],
    );
  }
}

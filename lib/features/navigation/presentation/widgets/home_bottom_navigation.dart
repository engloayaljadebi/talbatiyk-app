import 'package:flutter/material.dart';

class HomeBottomNavigation extends StatelessWidget {
  const HomeBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
    this.ordersBadgeCount = 0,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;
  final int ordersBadgeCount;

  static const Color _selectedColor = Color(0xFFE53935);
  static const Color _unselectedColor = Color(0xFF8E8E93);
  static const Color _backgroundColor = Color(0xFFF7F7F8);

  static const List<_NavigationItem> _items = [
    _NavigationItem(
      label: 'الرئيسية',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
    ),
    _NavigationItem(
      label: 'تصفح',
      icon: Icons.inventory_2_outlined,
      selectedIcon: Icons.inventory_2_rounded,
    ),
    _NavigationItem(
      label: 'السلة',
      icon: Icons.shopping_cart_outlined,
      selectedIcon: Icons.shopping_cart_rounded,
    ),
    _NavigationItem(
      label: 'الطلبات',
      icon: Icons.receipt_long_outlined,
      selectedIcon: Icons.receipt_long_rounded,
    ),
    _NavigationItem(
      label: 'الحساب',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_items.length, (index) {
          final bool isSelected = currentIndex == index;

          return Expanded(
            child: _NavigationButton(
              item: _items[index],
              isSelected: isSelected,
              badgeCount: index == 3 ? ordersBadgeCount : 0,
              onTap: () => onDestinationSelected(index),
            ),
          );
        }),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.item,
    required this.isSelected,
    required this.badgeCount,
    required this.onTap,
  });

  final _NavigationItem item;
  final bool isSelected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        splashColor: HomeBottomNavigation._selectedColor.withValues(
          alpha: 0.10,
        ),
        highlightColor: HomeBottomNavigation._selectedColor.withValues(
          alpha: 0.05,
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: isSelected
                ? HomeBottomNavigation._selectedColor.withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: SizedBox(
                  key: ValueKey(isSelected),
                  width: 38,
                  height: 25,
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        isSelected ? item.selectedIcon : item.icon,
                        size: isSelected ? 23 : 21,
                        color: isSelected
                            ? HomeBottomNavigation._selectedColor
                            : HomeBottomNavigation._unselectedColor,
                      ),
                      if (badgeCount > 0)
                        PositionedDirectional(
                          top: -2,
                          end: -1,
                          child: Container(
                            key: const ValueKey<String>('orders-badge'),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: const BoxDecoration(
                              color: HomeBottomNavigation._selectedColor,
                              borderRadius: BorderRadius.all(
                                Radius.circular(999),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              badgeCount > 99 ? '99+' : '$badgeCount',
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
              ),
              const SizedBox(height: 2),
              Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  height: 1,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected
                      ? HomeBottomNavigation._selectedColor
                      : HomeBottomNavigation._unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavigationItem {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

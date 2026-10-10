import 'package:flutter/material.dart';

import '../../../products/presentation/pages/products_page.dart';
import '../../../stores/presentation/pages/stores_page.dart';

/// One discovery destination in the existing five-tab shell.
/// No new bottom-navigation index or order/cart behavior is introduced.
class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});

  @override
  State<BrowsePage> createState() => BrowsePageState();
}

class BrowsePageState extends State<BrowsePage> {
  int _selectedIndex = 0;
  bool _storesVisited = false;

  /// Preserve existing Home > View Products navigation contract.
  void showProducts() {
    if (_selectedIndex != 0) setState(() => _selectedIndex = 0);
  }

  void _selectTab(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) _storesVisited = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('تصفح'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: BrowseTabs(
              selectedIndex: _selectedIndex,
              onSelected: _selectTab,
            ),
          ),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                const ProductsPage(embedded: true),
                if (_storesVisited)
                  const StoresPage()
                else
                  const SizedBox.shrink(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Independent presentation widget for deterministic interaction tests.
class BrowseTabs extends StatelessWidget {
  const BrowseTabs({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: _BrowseTab(
            label: 'المنتجات',
            icon: Icons.inventory_2_outlined,
            selected: selectedIndex == 0,
            onTap: () => onSelected(0),
            selectedColor: scheme.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _BrowseTab(
            label: 'المتاجر',
            icon: Icons.storefront_outlined,
            selected: selectedIndex == 1,
            onTap: () => onSelected(1),
            selectedColor: scheme.primary,
          ),
        ),
      ],
    );
  }
}

class _BrowseTab extends StatelessWidget {
  const _BrowseTab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? selectedColor.withValues(alpha: 0.09)
          : const Color(0xFFF7F7F8),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            border: Border.all(
              color: selected
                  ? selectedColor.withValues(alpha: 0.32)
                  : Colors.transparent,
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 19,
                color: selected ? selectedColor : const Color(0xFF71717A),
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? selectedColor : const Color(0xFF52525B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

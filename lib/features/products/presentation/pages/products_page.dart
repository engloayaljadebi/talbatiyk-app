import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/products_provider.dart';
import '../widgets/filter_button.dart';
import '../widgets/product_filter_sheet.dart';
import '../widgets/product_grid.dart';
import '../widgets/product_list.dart';
import '../widgets/view_toggle.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    // التخلص من متحكم البحث عند إغلاق الصفحة.
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(productDiscoveryProvider);
    final state = controller.state;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('المنتجات'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          ViewToggle(isGrid: state.isGrid, onChanged: controller.changeView),
          FilterButton(
            isActive: controller.hasActiveFilters,
            onPressed: _openFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: controller.search,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الشركة أو الفئة',
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: state.search.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'مسح البحث',
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () {
                          _searchController.clear();
                          controller.search('');
                        },
                      ),
                filled: true,
                fillColor: const Color(0xFFF4F4F6),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          if (controller.hasActiveFilters)
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_alt_rounded,
                    size: 18,
                    color: Color(0xFFE53935),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${state.products.length} نتيجة بعد الفلترة',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: controller.clearFilters,
                    child: const Text('مسح الفلاتر'),
                  ),
                ],
              ),
            ),
          Expanded(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final controller = ref.read(productDiscoveryProvider);
    final state = controller.state;

    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      );
    }

    if (state.errorMessage != null) {
      return _ProductsMessage(
        icon: Icons.cloud_off_rounded,
        title: state.errorMessage!,
        buttonText: 'إعادة المحاولة',
        onPressed: controller.loadProducts,
      );
    }

    if (state.products.isEmpty) {
      final hasCriteria = state.hasSearch || controller.hasActiveFilters;

      return _ProductsMessage(
        icon: Icons.search_off_rounded,
        title: hasCriteria ? 'لا توجد منتجات مطابقة' : 'لا توجد منتجات حاليًا',
        buttonText: hasCriteria ? 'عرض كل المنتجات' : null,
        onPressed: hasCriteria ? _clearAll : null,
      );
    }

    return state.isGrid
        ? ProductGrid(products: state.products)
        : ProductList(products: state.products);
  }

  /// يفتح صفحة إضافة المنتج.
  ///
  /// عند حفظ المنتج، يقوم ProductsController بتحديث قائمة المنتجات،
  Future<void> _openFilters() async {
    final controller = ref.read(productDiscoveryProvider);
    final state = controller.state;

    if (controller.minimumPrice == 0 && controller.maximumPrice == 0) {
      return;
    }

    final result = await showModalBottomSheet<ProductFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ProductFilterSheet(
          categories: controller.categories,
          brands: controller.brands,
          selectedCategory: state.selectedCategory,
          selectedBrand: state.selectedBrand,
          selectedAvailability: state.availability,
          minimumPrice: controller.minimumPrice,
          maximumPrice: controller.maximumPrice,
          selectedMinPrice: state.minPrice,
          selectedMaxPrice: state.maxPrice,
        );
      },
    );

    if (!mounted || result == null) return;

    controller.applyFilters(
      category: result.category,
      brand: result.brand,
      availability: result.availability,
      minPrice: result.minPrice,
      maxPrice: result.maxPrice,
    );
  }

  void _clearAll() {
    _searchController.clear();
    ref.read(productDiscoveryProvider).clearAll();
  }
}

class _ProductsMessage extends StatelessWidget {
  const _ProductsMessage({
    required this.icon,
    required this.title,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: Colors.grey.shade400),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}

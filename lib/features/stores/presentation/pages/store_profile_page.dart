import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import '../../../supplier_follow/presentation/providers/supplier_follow_provider.dart';

/// Public customer view. Never uses owner-only BusinessController.show or
/// business-product management routes (which require an active membership).
class StoreProfilePage extends ConsumerWidget {
  const StoreProfilePage({super.key, required this.store});

  final SupplierCandidateEntity store;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final follow = ref.watch(supplierFollowProvider(store.id));
    final discovery = ref.watch(productDiscoveryProvider);
    final allLoaded = discovery.loadedDiscoveryProducts;
    final products = allLoaded
        .where((p) => p.supplierId == store.id)
        .toList(growable: false);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('الملف التجاري'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            child: Column(
              children: [
                Container(
                  height: 76,
                  width: 76,
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.storefront_rounded,
                    color: scheme.primary,
                    size: 37,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  store.name,
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                const Text(
                  'متجر تجاري',
                  style: TextStyle(color: Color(0xFF71717A)),
                ),
                const SizedBox(height: 16),
                FilledButton.tonalIcon(
                  key: const ValueKey<String>('store-follow-button'),
                  onPressed: follow.canToggle
                      ? () async {
                          await follow.toggle();
                          if (!context.mounted) return;
                          if (follow.errorMessage != null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(follow.errorMessage!)),
                            );
                          }
                        }
                      : null,
                  icon: follow.isLoading || follow.isUpdating
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          follow.isFollowing == true
                              ? Icons.check_circle_outline
                              : Icons.add_rounded,
                        ),
                  label: Text(
                    follow.isFollowing == true
                        ? 'تتم المتابعة'
                        : 'متابعة المتجر',
                  ),
                ),
                if (follow.errorMessage != null) ...[
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: follow.loadStatus,
                    child: const Text('إعادة التحقق من المتابعة'),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.inventory_2_outlined, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'منتجات المتجر الظاهرة في الكتالوج',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  '${products.length}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Text(
              'المنتجات هنا من البيانات المحملة حاليًا؛ ليست بالضرورة جميع منتجات المتجر.',
              style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
            ),
          ),
          Expanded(
            child: discovery.state.isLoading && allLoaded.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        discovery.state.errorMessage != null
                            ? 'تعذر تحميل منتجات الكتالوج حاليًا.'
                            : 'لا توجد منتجات لهذا المتجر ضمن الكتالوج المحمل.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ProductGrid(products: products),
          ),
        ],
      ),
    );
  }
}

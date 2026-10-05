import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/products_entity.dart';
import '../providers/products_provider.dart';
import '../widgets/product_image.dart';
import 'add_product_page.dart';
import 'product_details_page.dart';

class MyProductsPage extends ConsumerWidget {
  const MyProductsPage({
    super.key,
    required this.businessId,
    required this.businessName,
  });

  final String businessId;
  final String businessName;

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(supplierManagedProductsProvider(businessId));

    await ref.read(supplierManagedProductsProvider(businessId).future);
  }

  Future<void> _openProduct(
    BuildContext context,
    WidgetRef ref,
    ProductEntity product,
  ) async {
    await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) =>
            ProductDetailsPage(product: product, managedBusinessId: businessId),
      ),
    );

    ref.invalidate(supplierManagedProductsProvider(businessId));
  }

  Future<void> _createProduct(BuildContext context, WidgetRef ref) async {
    final created = await Navigator.of(context).push<ProductEntity>(
      MaterialPageRoute<ProductEntity>(
        builder: (_) =>
            AddProductPage(supplierId: businessId, supplierName: businessName),
      ),
    );

    if (created == null) {
      return;
    }

    ref.invalidate(supplierManagedProductsProvider(businessId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(
      supplierManagedProductsProvider(businessId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(title: const Text('منتجاتي'), centerTitle: true),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('my-products-create'),
        onPressed: () => _createProduct(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج'),
      ),
      body: productsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) {
          return _ManagementError(
            onRetry: () {
              ref.invalidate(supplierManagedProductsProvider(businessId));
            },
          );
        },
        data: (products) {
          return RefreshIndicator(
            onRefresh: () => _refresh(ref),
            child: products.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    children: [
                      const SizedBox(height: 90),
                      Icon(
                        Icons.inventory_2_outlined,
                        size: 68,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد منتجات في هذا النشاط',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'يمكنك إضافة منتج جديد من زر إضافة منتج.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    itemCount: products.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _BusinessSummary(
                          businessName: businessName,
                          productCount: products.length,
                        );
                      }

                      final product = products[index - 1];

                      return _ManagedProductTile(
                        product: product,
                        onTap: () => _openProduct(context, ref, product),
                      );
                    },
                  ),
          );
        },
      ),
    );
  }
}

class _BusinessSummary extends StatelessWidget {
  const _BusinessSummary({
    required this.businessName,
    required this.productCount,
  });

  final String businessName;
  final int productCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(Icons.storefront_outlined),
        title: Text(businessName),
        subtitle: Text('$productCount منتج'),
      ),
    );
  }
}

class _ManagedProductTile extends StatelessWidget {
  const _ManagedProductTile({required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        key: ValueKey('managed-product-${product.id}'),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        leading: SizedBox(
          width: 58,
          height: 58,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: ProductImage(imageUrl: product.displayImagePath),
          ),
        ),
        title: Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${product.price.toStringAsFixed(0)} ر.ي'),
              const SizedBox(height: 2),
              Text('الكمية: ${product.quantity}'),
              const SizedBox(height: 2),
              Text(product.isAvailable ? 'متاح' : 'غير متاح'),
              if (product.needsSync) ...[
                const SizedBox(height: 4),
                Text(
                  'بانتظار المزامنة',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.tertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_left_rounded),
      ),
    );
  }
}

class _ManagementError extends StatelessWidget {
  const _ManagementError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 54),
            const SizedBox(height: 12),
            const Text(
              'تعذر تحميل منتجات النشاط.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

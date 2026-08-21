import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';

class LatestProductsSection extends ConsumerWidget {
  const LatestProductsSection({super.key, this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(productDiscoveryProvider);
    final state = controller.state;
    final products = controller.latestProducts;

    if (state.isLoading && products.isEmpty) {
      return const SizedBox(
        height: 310,
        child: Center(
          child: CircularProgressIndicator(color: Color(0xFFE53935)),
        ),
      );
    }

    if (state.errorMessage != null && products.isEmpty) {
      return _LatestProductsError(
        message: state.errorMessage!,
        onRetry: controller.loadProducts,
      );
    }

    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'أحدث المنتجات',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'عرض الكل',
                  style: TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 310,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];

              return SizedBox(
                width: 180,
                child: ProductCard(key: ValueKey(product.id), product: product),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _LatestProductsError extends StatelessWidget {
  const _LatestProductsError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 40,
              color: Colors.grey,
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

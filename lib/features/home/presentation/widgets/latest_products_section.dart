import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../products/presentation/widgets/product_grid.dart';

/// قسم أحدث المنتجات في Home.
///
/// لا يملك قالب منتج خاصًا به.
/// يستخدم ProductCard الرسمية ونفس Geometry Contract
/// المستخدم في ProductGrid.
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
        height: 260,
        child: Center(child: CircularProgressIndicator()),
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

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: ProductGrid.horizontalPadding,
            ),
            child: Row(
              children: [
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'عرض الكل',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                const Text(
                  'أحدث المنتجات',
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Color(0xFF202020),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),

          // نفس عرض وارتفاع ProductCard داخل ProductGrid تمامًا.
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = ProductGrid.cardWidthFor(constraints.maxWidth);

              final cardHeight = ProductGrid.cardHeightFor(
                constraints.maxWidth,
              );

              return SizedBox(
                height: cardHeight,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: ProductGrid.horizontalPadding,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: products.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(width: ProductGrid.crossAxisSpacing),
                  itemBuilder: (context, index) {
                    final product = products[index];

                    return SizedBox(
                      width: cardWidth,
                      height: cardHeight,
                      child: ProductCard(
                        key: ValueKey<String>(
                          'home-latest-product-${product.id}',
                        ),
                        product: product,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
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
      height: 150,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 32,
              color: Colors.grey,
            ),
            const SizedBox(height: 7),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 7),
            TextButton(onPressed: onRetry, child: const Text('إعادة المحاولة')),
          ],
        ),
      ),
    );
  }
}

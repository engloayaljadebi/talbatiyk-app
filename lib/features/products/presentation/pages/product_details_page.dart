import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/products_entity.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_selector.dart';

class ProductDetailsPage extends ConsumerWidget {
  const ProductDetailsPage({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(
      cartProvider.select((cart) => cart.quantityOf(product.id)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 290,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              // يعرض الصورة المحلية أولًا، ثم صورة السحابة عند عدم وجودها.
              child: ProductImage(imageUrl: product.displayImagePath),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList.list(
              children: [
                _ProductHeader(product: product),
                const SizedBox(height: 14),
                _ProductInformation(product: product),
                const SizedBox(height: 14),
                _DescriptionCard(description: product.description),
                if (product.colors.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _ColorsCard(colors: product.colors),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ProductCartBar(
        product: product,
        quantity: quantity,
        onAdd: () => ref.read(cartProvider).addProduct(product),
        onRemove: () => ref.read(cartProvider).decreaseProduct(product.id),
      ),
    );
  }
}

class _ProductHeader extends StatelessWidget {
  const _ProductHeader({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _AvailabilityBadge(isAvailable: product.isAvailable),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            product.brand,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                '${_formatPrice(product.price)} ر.ي',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (product.discount > 0) ...[
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'خصم ${product.discount.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      color: Color(0xFFE53935),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isAvailable ? 'متوفر' : 'غير متوفر',
        style: TextStyle(
          color: color.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProductInformation extends StatelessWidget {
  const _ProductInformation({required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _InformationItem(
              icon: Icons.category_outlined,
              label: 'الفئة',
              value: product.category.isEmpty ? 'غير محددة' : product.category,
            ),
          ),
          Container(width: 1, height: 44, color: Colors.grey.shade200),
          Expanded(
            child: _InformationItem(
              icon: Icons.star_rounded,
              label: 'التقييم',
              value: product.rating > 0
                  ? product.rating.toStringAsFixed(1)
                  : 'جديد',
            ),
          ),
          if (product.quantity > 0) ...[
            Container(width: 1, height: 44, color: Colors.grey.shade200),
            Expanded(
              child: _InformationItem(
                icon: Icons.inventory_2_outlined,
                label: 'المخزون',
                value: '${product.quantity}',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  const _InformationItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 21, color: const Color(0xFFE53935)),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.description});

  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وصف المنتج',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          Text(
            description.trim().isEmpty
                ? 'لا توجد تفاصيل إضافية لهذا المنتج حاليًا.'
                : description,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorsCard extends StatelessWidget {
  const _ColorsCard({required this.colors});

  final List<String> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الألوان المتوفرة',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: colors
                .map((color) {
                  return Chip(
                    label: Text(color),
                    backgroundColor: const Color(0xFFF4F4F6),
                    side: BorderSide.none,
                  );
                })
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _ProductCartBar extends StatelessWidget {
  const _ProductCartBar({
    required this.product,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  final ProductEntity product;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 12,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'السعر',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${_formatPrice(product.price)} ر.ي',
                      style: const TextStyle(
                        color: Color(0xFFE53935),
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 190,
                child: !product.isAvailable
                    ? const _UnavailableAction()
                    : quantity == 0
                    ? AddToCartButton(onPressed: onAdd)
                    : QuantitySelector(
                        quantity: quantity,
                        onAdd: onAdd,
                        onRemove: onRemove,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnavailableAction extends StatelessWidget {
  const _UnavailableAction();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'المنتج غير متوفر',
        style: TextStyle(color: Color(0xFF8E8E93), fontWeight: FontWeight.w600),
      ),
    );
  }
}

String _formatPrice(double price) {
  if (price == price.truncateToDouble()) return price.toStringAsFixed(0);
  return price.toStringAsFixed(2);
}

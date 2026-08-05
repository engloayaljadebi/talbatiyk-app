import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/products_entity.dart';
import '../providers/products_provider.dart';
import '../widgets/add_to_cart_button.dart';
import '../widgets/product_image.dart';
import '../widgets/quantity_selector.dart';
import 'add_product_page.dart';

enum _ProductAction { edit, delete }

class ProductDetailsPage extends ConsumerStatefulWidget {
  const ProductDetailsPage({super.key, required this.product});

  final ProductEntity product;

  @override
  ConsumerState<ProductDetailsPage> createState() {
    return _ProductDetailsPageState();
  }
}

class _ProductDetailsPageState extends ConsumerState<ProductDetailsPage> {
  late ProductEntity _product;

  @override
  void initState() {
    super.initState();
    _product = widget.product;
  }

  /// مؤقتًا نسمح بإدارة منتجات المورد المحلي فقط.
  ///
  /// لاحقًا سيعتمد هذا الشرط على المستخدم المسجل دخوله.
  bool get _canManageProduct {
    return _product.supplierId == 'local-supplier';
  }

  @override
  Widget build(BuildContext context) {
    final quantity = ref.watch(
      cartProvider.select((cart) => cart.quantityOf(_product.id)),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_canManageProduct)
            PopupMenuButton<_ProductAction>(
              tooltip: 'إدارة المنتج',
              onSelected: (action) async {
                switch (action) {
                  case _ProductAction.edit:
                    await _openEditPage();
                    break;
                  case _ProductAction.delete:
                    await _confirmDelete();
                    break;
                }
              },
              itemBuilder: (context) {
                return const [
                  PopupMenuItem(
                    value: _ProductAction.edit,
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined),
                        SizedBox(width: 10),
                        Text('تعديل المنتج'),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _ProductAction.delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, color: Colors.red),
                        SizedBox(width: 10),
                        Text('حذف المنتج', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 290,
              color: Colors.white,
              padding: const EdgeInsets.all(24),

              // يعرض الصورة المحلية أولًا ثم السحابية.
              child: ProductImage(imageUrl: _product.displayImagePath),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
            sliver: SliverList.list(
              children: [
                _ProductHeader(product: _product),
                const SizedBox(height: 14),
                _ProductInformation(product: _product),
                const SizedBox(height: 14),
                _DescriptionCard(description: _product.description),
                if (_product.colors.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  _ColorsCard(colors: _product.colors),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _ProductCartBar(
        product: _product,
        quantity: quantity,
        onAdd: () {
          ref.read(cartProvider).addProduct(_product);
        },
        onRemove: () {
          ref.read(cartProvider).decreaseProduct(_product.id);
        },
      ),
    );
  }

  /// يفتح نفس نموذج المنتج في وضع التعديل.
  Future<void> _openEditPage() async {
    final updatedProduct = await Navigator.of(context).push<ProductEntity>(
      MaterialPageRoute<ProductEntity>(
        builder: (context) {
          return AddProductPage(product: _product);
        },
      ),
    );

    if (!mounted || updatedProduct == null) {
      return;
    }

    // نحدّث صفحة التفاصيل فورًا بالبيانات الجديدة.
    setState(() {
      _product = updatedProduct;
    });
  }

  /// يعرض رسالة تأكيد قبل تنفيذ الحذف.
  Future<void> _confirmDelete() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('حذف المنتج'),
              content: Text('هل تريد حذف المنتج "${_product.name}"؟'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('حذف'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    try {
      await ref.read(productsProvider).deleteProduct(_product.id);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'تم حذف المنتج محليًا وستُزامن العملية عند توفر الإنترنت.',
          ),
        ),
      );

      // نغلق صفحة التفاصيل لأن المنتج لم يعد موجودًا في القائمة.
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('تعذر حذف المنتج: $error')));
    }
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

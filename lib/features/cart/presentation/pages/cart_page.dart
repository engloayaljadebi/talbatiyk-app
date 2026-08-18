import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_image.dart';

/// صفحة سلة المشتريات.
///
/// المهام:
/// - عرض المنتجات الموجودة داخل السلة.
/// - التحكم في الكميات.
/// - حذف منتج أو تفريغ السلة.
/// - دعم منتجات من عدة موردين داخل الطلبية.
/// - إرسال بيانات المورد الخاصة بكل عنصر من عناصر الطلبية.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static const Color _primaryColor = Color(0xFFE53935);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CartController cart = ref.watch(cartProvider);
    final ordersController = ref.watch(ordersProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('السلة'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              tooltip: 'تفريغ السلة',
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: () {
                _confirmClearCart(context, ref);
              },
            ),
        ],
      ),
      body: cart.isEmpty
          ? const _EmptyCart()
          : Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 92),
              child: Column(
                children: [
                  if (cart.supplierName.isNotEmpty) ...[
                    _SupplierBanner(supplierName: cart.supplierName),
                    const SizedBox(height: 12),
                  ],
                  Expanded(
                    child: ListView.separated(
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        return _CartItemCard(item: cart.items[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  _CartSummary(
                    totalQuantity: cart.totalQuantity,
                    totalPrice: cart.totalPrice,
                    isSubmitting: ordersController.state.isSubmitting,
                    onSubmit: () {
                      _submitOrder(context, ref, cart);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  /// عرض رسالة تأكيد قبل تفريغ السلة.
  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final bool shouldClear =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext dialogContext) {
            return AlertDialog(
              title: const Text('تفريغ السلة'),
              content: const Text('هل تريد حذف جميع المنتجات من السلة؟'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: FilledButton.styleFrom(backgroundColor: _primaryColor),
                  child: const Text('حذف'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldClear) {
      ref.read(cartProvider).clear();
    }
  }

  /// إنشاء طلبية من منتجات السلة.
  ///
  /// كل عنصر داخل الطلبية يحمل بيانات المورد الخاصة به،
  /// لذلك يمكن إرسال منتجات من عدة موردين في نفس الطلب.
  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    CartController cart,
  ) async {
    if (cart.isEmpty) {
      return;
    }

    final CreateOrderRequest request = CreateOrderRequest(
      items: cart.items
          .map((CartItemEntity item) {
            return OrderItemEntity(
              productId: item.product.id,
              productName: item.product.name,
              unitPrice: item.product.price,
              quantity: item.quantity,
              supplierId: item.product.supplierId,
              supplierName: item.product.supplierName,
              imageUrl: item.product.imageUrl,
            );
          })
          .toList(growable: false),
    );

    final ordersController = ref.read(ordersProvider);

    final OrderEntity? createdOrder = await ordersController.createOrder(
      request,
    );

    if (!context.mounted) {
      return;
    }

    if (createdOrder == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ordersController.state.errorMessage ??
                  'تعذر إرسال الطلبية، حاول مرة أخرى',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );

      return;
    }

    cart.clear();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تم إرسال الطلبية #${createdOrder.id} بنجاح'),
          backgroundColor: Colors.green.shade700,
        ),
      );
  }
}

/// بطاقة صغيرة تعرض مورد الطلبية الحالية.
class _SupplierBanner extends StatelessWidget {
  const _SupplierBanner({required this.supplierName});

  final String supplierName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _primaryBorderColor),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.storefront_outlined,
            color: Color(0xFFE53935),
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'المورد: $supplierName',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFFE53935),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const Color _primaryBorderColor = Color(0xFFFFCDD2);
}

/// واجهة السلة الفارغة.
class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 80),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                color: Color(0xFFFFEBEE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                size: 46,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'السلة فارغة',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف المنتجات التي تريدها إلى طلبيتك',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة منتج واحد داخل السلة.
class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: SizedBox(
              width: 82,
              height: 82,
              child: ProductImage(imageUrl: product.displayImagePath),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.brand,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                if (product.supplierName.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.supplierName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  '${_formatPrice(item.totalPrice)} ر.ي',
                  style: const TextStyle(
                    color: Color(0xFFE53935),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                tooltip: 'حذف المنتج',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () {
                  ref.read(cartProvider).removeProduct(product.id);
                },
              ),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove_rounded,
                      onPressed: () {
                        ref.read(cartProvider).decreaseProduct(product.id);
                      },
                    ),
                    SizedBox(
                      width: 30,
                      child: Text(
                        '${item.quantity}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add_rounded,
                      onPressed: () {
                        ref.read(cartProvider).addProduct(product);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// زر زيادة أو تقليل كمية المنتج.
class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      padding: EdgeInsets.zero,
      icon: Icon(icon, size: 18),
    );
  }
}

/// ملخص الكمية والإجمالي وزر إرسال الطلبية.
class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.totalQuantity,
    required this.totalPrice,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final int totalQuantity;
  final double totalPrice;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text('عدد المنتجات'),
              const Spacer(),
              Text(
                '$totalQuantity',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Text(
                'الإجمالي',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${_formatPrice(totalPrice)} ر.ي',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: isSubmitting ? null : onSubmit,
              icon: isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(isSubmitting ? 'جاري الإرسال...' : 'إرسال الطلبية'),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// تنسيق السعر دون أصفار عشرية غير ضرورية.
String _formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    return price.toStringAsFixed(0);
  }

  return price.toStringAsFixed(2);
}

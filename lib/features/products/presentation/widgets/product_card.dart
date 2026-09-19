import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../domain/entities/products_entity.dart';
import '../pages/product_details_page.dart';
import '../utils/product_cart_action.dart';
import 'add_to_cart_button.dart';
import 'product_image.dart';
import 'product_price.dart';

/// بطاقة منتج داخل Product Discovery.
///
/// المسؤولية:
/// - عرض معلومات المنتج الأساسية.
/// - فتح Product Details عند الضغط على البطاقة.
/// - توفير Add-to-Cart مباشر مع Follow Gate.
/// - عرض كمية المنتج الحالية داخل السلة.
///
/// لا تحتوي هذه البطاقة على Business Logic خاص بالمتابعة؛
/// التدفق المركزي موجود في addProductWithFollowGate().
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({super.key, required this.product});

  final ProductEntity product;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  bool _isProcessingCartAction = false;

  ProductEntity get product => widget.product;

  @override
  Widget build(BuildContext context) {
    final cartQuantity = ref.watch(
      cartProvider.select((cart) => cart.quantityOf(product.id)),
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Grid يعطي ارتفاعًا bounded، بينما ListView يعطي ارتفاعًا unbounded.
          // لذلك لا نستخدم Flex child إلا عندما يكون الارتفاع محددًا.
          final bool hasBoundedHeight = constraints.hasBoundedHeight;

          return Column(
            mainAxisSize: hasBoundedHeight
                ? MainAxisSize.max
                : MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: _openDetails,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 120,
                      width: double.infinity,
                      child: ProductImage(imageUrl: product.displayImagePath),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 6),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.brand,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ProductPrice(price: product.price),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // في Grid نثبت زر Cart أسفل البطاقة.
              // في ListView لا نضيف Spacer لأن الارتفاع غير محدود.
              if (hasBoundedHeight) const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                child: AddToCartButton(
                  quantity: cartQuantity,
                  isProcessing: _isProcessingCartAction,
                  onPressed: product.isAvailable ? _handleAddToCart : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _openDetails() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProductDetailsPage(product: product),
      ),
    );
  }

  Future<void> _handleAddToCart() async {
    if (_isProcessingCartAction) {
      return;
    }

    await addProductWithFollowGate(
      context: context,
      ref: ref,
      product: product,
      onProcessingChanged: (isProcessing) {
        if (!mounted) {
          return;
        }

        setState(() {
          _isProcessingCartAction = isProcessing;
        });
      },
    );
  }
}

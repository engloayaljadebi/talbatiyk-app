import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';

import '../../domain/entities/products_entity.dart';
import '../pages/product_details_page.dart';
import 'add_to_cart_button.dart';
import 'product_image.dart';
import 'product_price.dart';
import 'quantity_selector.dart';

class ProductCard extends ConsumerWidget {
  const ProductCard({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quantity = ref.watch(
      cartProvider.select((cart) => cart.quantityOf(product.id)),
    );

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailsPage(product: product),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              width: double.infinity,
              // نعطي الأولوية للصورة المحلية، ثم نستخدم رابط السحابة عند توفره.
              child: ProductImage(imageUrl: product.displayImagePath),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 36,
                    child: !product.isAvailable
                        ? const _UnavailableButton()
                        : quantity == 0
                        ? AddToCartButton(
                            onPressed: () {
                              ref.read(cartProvider).addProduct(product);
                            },
                          )
                        : QuantitySelector(
                            quantity: quantity,
                            onAdd: () {
                              ref.read(cartProvider).addProduct(product);
                            },
                            onRemove: () {
                              ref
                                  .read(cartProvider)
                                  .decreaseProduct(product.id);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableButton extends StatelessWidget {
  const _UnavailableButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F1F3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'غير متوفر',
        style: TextStyle(
          color: Color(0xFF8E8E93),
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

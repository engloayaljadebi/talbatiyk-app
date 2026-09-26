import 'package:flutter/material.dart';

import '../../domain/entities/products_entity.dart';
import 'product_card.dart';

/// الشبكة الرسمية لبطاقات المنتجات.
///
/// هذه القيم تمثل Layout Contract الخاص بـ ProductCard.
/// أي مكان يحتاج نفس حجم البطاقة يجب أن يستخدم هذه القيم
/// بدل إنشاء Width / Height مستقل.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<ProductEntity> products;

  static const int crossAxisCount = 2;

  static const double horizontalPadding = 12;
  static const double verticalPadding = 12;

  static const double crossAxisSpacing = 12;
  static const double mainAxisSpacing = 12;

  static const double childAspectRatio = 0.60;

  /// عرض ProductCard الرسمي عند توفر عرض الشاشة/الحاوية.
  static double cardWidthFor(double availableWidth) {
    final spacingWidth = crossAxisSpacing * (crossAxisCount - 1);

    final usableWidth = availableWidth - (horizontalPadding * 2) - spacingWidth;

    return usableWidth / crossAxisCount;
  }

  /// ارتفاع ProductCard الناتج عن نفس childAspectRatio
  /// المستخدم في ProductGrid.
  static double cardHeightFor(double availableWidth) {
    return cardWidthFor(availableWidth) / childAspectRatio;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        horizontalPadding,
        verticalPadding,
        horizontalPadding,
        90,
      ),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
        childAspectRatio: childAspectRatio,
      ),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(key: ValueKey(product.id), product: product);
      },
    );
  }
}

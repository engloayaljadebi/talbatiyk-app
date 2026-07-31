import 'package:flutter/material.dart';

import '../../domain/entities/products_entity.dart';
import 'product_card.dart';

class ProductList extends StatelessWidget {
  const ProductList({super.key, required this.products});

  final List<ProductEntity> products;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          quantity: product.quantity,
          onAdd: () {},
          onRemove: () {},
        );
      },
    );
  }
}

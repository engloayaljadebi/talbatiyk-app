import 'package:flutter/material.dart';

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.shopping_cart_outlined),
        title: const Text('سلة التسوق'),
        subtitle: const Text('لا توجد منتجات حالياً'),
        trailing: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
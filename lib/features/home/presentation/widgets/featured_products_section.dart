import 'package:flutter/material.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'المنتجات المميزة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: Icon(Icons.phone_android),
            title: Text('منتج مميز'),
            subtitle: Text('سيتم إضافة المنتجات لاحقاً'),
          ),
        ),
      ],
    );
  }
}
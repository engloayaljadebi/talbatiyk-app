import 'package:flutter/material.dart';

class ProductFilterSheet extends StatelessWidget {
  const ProductFilterSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          const Text(
            'فلترة المنتجات',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 20),

          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('حسب الفئة'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.branding_watermark),
            title: const Text('حسب الشركة'),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.price_change),
            title: const Text('حسب السعر'),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

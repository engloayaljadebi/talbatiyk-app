import 'package:flutter/material.dart';

class LatestProductsSection extends StatelessWidget {
  const LatestProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'أحدث المنتجات',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        SizedBox(height: 12),

        Card(
          child: ListTile(
            leading: Icon(Icons.new_releases_outlined),
            title: Text('آخر المنتجات'),
            subtitle: Text('سيتم تحميل المنتجات من قاعدة البيانات'),
          ),
        ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_card.dart';

class LatestProductsSection extends StatelessWidget {
  const LatestProductsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final products = [
      ProductEntity(
        id: '1',
        name: 'Samsung Galaxy S25 Ultra',
        price: 420000,
        imageUrl: 'assets/images/jp3.jpeg',
        category: 'هواتف',
        brand: 'Samsung',
        isAvailable: true,
        rating: 4.8,
      ),

      ProductEntity(
        id: '2',
        name: 'Apple AirPods Pro',
        price: 85000,
        imageUrl: 'assets/images/jp1.jpeg',
        category: 'سماعات',
        brand: 'Apple',
        isAvailable: true,
        rating: 4.7,
      ),

      ProductEntity(
        id: '3',
        name: 'Anker 65W Charger',
        price: 18000,
        imageUrl: 'assets/images/jp2.jpeg',
        category: 'شواحن',
        brand: 'Anker',
        isAvailable: true,
        rating: 4.5,
      ),

      ProductEntity(
        id: '4',
        name: 'Apple Watch',
        price: 145000,
        imageUrl: 'assets/images/jp3.jpeg',
        category: 'ساعات',
        brand: 'Apple',
        isAvailable: true,
        rating: 4.6,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                'أحدث المنتجات',

                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              TextButton(onPressed: () {}, child: const Text('عرض الكل')),
            ],
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 310,

          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),

            scrollDirection: Axis.horizontal,

            itemCount: products.length,

            itemBuilder: (context, index) {
              final product = products[index];

              return SizedBox(
                width: 180,

                child: Padding(
                  padding: const EdgeInsets.only(left: 12),

                  child: ProductCard(
                    product: product,

                    quantity: 0,

                    onAdd: () {},

                    onRemove: () {},
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

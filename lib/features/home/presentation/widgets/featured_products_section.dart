import 'package:flutter/material.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_card.dart';

class FeaturedProductsSection extends StatelessWidget {
  const FeaturedProductsSection({super.key, this.onViewAll});

  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    const products = [
      ProductEntity(
        id: 'featured-iphone-15-pro',
        name: 'iPhone 15 Pro',
        price: 390000,
        imageUrl: 'assets/images/jp1.jpeg',
        category: 'هواتف',
        brand: 'Apple',
        isAvailable: true,
        discount: 60,
      ),
      ProductEntity(
        id: 'featured-samsung-galaxy-s25',
        name: 'Samsung Galaxy S25',
        price: 330000,
        imageUrl:
            'https://yemenmobile.com.ye/uploads/images/202410/image_753x_67183d0a346a0.webp',
        category: 'هواتف',
        brand: 'Samsung',
        isAvailable: true,
        discount: 50,
      ),
      ProductEntity(
        id: 'featured-anker-wireless-headphones',
        name: 'سماعة لاسلكية',
        price: 18000,
        imageUrl: 'assets/images/jp3.jpeg',
        category: 'سماعات',
        brand: 'Anker',
        isAvailable: true,
        discount: 20,
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
                'المنتجات المميزة ⭐',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(onPressed: onViewAll, child: const Text('عرض الكل')),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 330,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];

              return SizedBox(
                width: 190,
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: ProductCard(
                    key: ValueKey(product.id),
                    product: product,
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

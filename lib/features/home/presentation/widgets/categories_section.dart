import 'package:flutter/material.dart';

class CategoriesSection extends StatelessWidget {
  const CategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      'هواتف',
      'سماعات',
      'شواحن',
      'إكسسوارات', 'هواتف',
      'سماعات',
      'شواحن',
      'إكسسوارات',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الأقسام',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        SizedBox(
          height: 90,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            itemBuilder: (context, index) {
              return Container(
                width: 90,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Center(
                    child: Text(
                      categories[index],
                    ),
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
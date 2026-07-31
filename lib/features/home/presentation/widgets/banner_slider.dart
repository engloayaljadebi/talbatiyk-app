import 'package:flutter/material.dart';

class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  final List<String> banners = const [
    'https://picsum.photos/800/300?random=1',
    'https://picsum.photos/800/300?random=2',
    'https://picsum.photos/800/300?random=3',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        itemCount: banners.length,
        controller: PageController(
          viewportFraction: 0.95,
        ),
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: NetworkImage(
                  banners[index],
                ),
                fit: BoxFit.cover,
              ),
            ),
          );
        },
      ),
    );
  }
}
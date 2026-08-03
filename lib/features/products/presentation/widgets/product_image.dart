import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,

      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),

        child: imageUrl.isEmpty
            ? _placeholder()
            : imageUrl.startsWith('http')
            ? Image.network(
                imageUrl,
                fit: BoxFit.contain,

                headers: const {'User-Agent': 'Mozilla/5.0'},

                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return _loading();
                },

                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Image Error: $error');
                  return _placeholder();
                },
              )
            : Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _placeholder();
                },
              ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,

      child: const Center(
        child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
      ),
    );
  }

  Widget _loading() {
    return Container(
      color: Colors.grey.shade100,

      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

import 'dart:io';

import 'package:flutter/material.dart';

/// يعرض صورة المنتج سواء كانت من الإنترنت أو ملفات التطبيق أو assets.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.2,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: _buildImage(),
      ),
    );
  }

  /// يحدد نوع الصورة اعتمادًا على مسارها.
  Widget _buildImage() {
    final imagePath = imageUrl.trim();

    if (imagePath.isEmpty) {
      return _placeholder();
    }

    // صورة مخزنة على خادم أو سحابة.
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return Image.network(
        imagePath,
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
      );
    }

    // صورة موجودة داخل مجلد assets في المشروع.
    if (imagePath.startsWith('assets/')) {
      return Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return _placeholder();
        },
      );
    }

    // صورة اختارها المورد من الهاتف وحُفظت داخل ملفات التطبيق.
    return Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        debugPrint('Local Image Error: $error');
        return _placeholder();
      },
    );
  }

  /// يظهر عندما لا توجد صورة أو يفشل تحميلها.
  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 50, color: Colors.grey),
      ),
    );
  }

  /// يظهر أثناء تحميل صورة الإنترنت.
  Widget _loading() {
    return Container(
      color: Colors.grey.shade100,
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }
}

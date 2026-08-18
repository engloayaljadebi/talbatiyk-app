import 'package:flutter/material.dart';

/// ---------------------------------------------------------------------------
/// File: banner_slider.dart
///
/// المسؤولية:
/// - عرض رسالة ترويجية محلية بسيطة في الصفحة الرئيسية.
/// - عدم الاعتماد على صور أو خدمات خارجية غير تابعة للمشروع.
///
/// لا يحتوي:
/// - Network calls.
/// - Remote image URLs.
/// - Business logic.
/// - Navigation غير منفذ.
/// ---------------------------------------------------------------------------
class BannerSlider extends StatelessWidget {
  const BannerSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أفضل العروض',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'منتجات أصلية بأسعار منافسة',
            style: TextStyle(color: Colors.white),
          ),
          Spacer(),
          Text(
            'اكتشف المنتجات والموردين المناسبين لنشاطك',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

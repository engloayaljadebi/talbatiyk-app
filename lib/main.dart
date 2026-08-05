// محتوى الملف:
// - يمثل نقطة التشغيل الوحيدة لتطبيق طلبيتك.
// - يستدعي bootstrap لتجهيز التطبيق وتشغيله.

import 'bootstrap.dart';

/// يبدأ تشغيل التطبيق بعد إكمال جميع عمليات التهيئة.
Future<void> main() async {
  await bootstrap();
}

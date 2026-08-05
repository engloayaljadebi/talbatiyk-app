// محتوى الملف:
// - تهيئة Flutter قبل استخدام الخدمات.
// - تحديد بيئة تشغيل التطبيق.
// - تسجيل الاعتمادات والخدمات.
// - تغليف التطبيق بـ Riverpod.
// - تشغيل TalbatiykApp.

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/app_initializer.dart';
import 'core/config/flavors.dart';

/// يجهز الخدمات والإعدادات المطلوبة ثم يشغّل التطبيق.
Future<void> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // نحدد البيئة أولًا حتى تستطيع الخدمات قراءة الإعدادات أثناء تهيئتها.
  AppConfig.initialize(FlavorConfig.development);

  // تسجيل الخدمات والاعتمادات العامة للتطبيق.
  await AppInitializer.initialize();

  runApp(const ProviderScope(child: TalbatiykApp()));
}

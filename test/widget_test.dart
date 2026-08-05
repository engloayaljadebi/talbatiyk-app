// محتوى الملف:
// - التحقق من أن تطبيق طلبيتك يُنشأ بدون أخطاء.
// - استخدام قاعدة بيانات مؤقتة داخل الذاكرة.
// - منع الاختبار من التعامل مع قاعدة بيانات الجهاز الحقيقية.
// - تنظيف موارد الاختبار بعد اكتماله.

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/app.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';

void main() {
  testWidgets('Talbatiyk app starts successfully', (WidgetTester tester) async {
    // إنشاء قاعدة بيانات مؤقتة تعمل داخل الذاكرة فقط.
    final AppDatabase database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    // إغلاق قاعدة البيانات تلقائيًا بعد انتهاء الاختبار.
    addTearDown(database.close);

    // تشغيل التطبيق مع استبدال قاعدة البيانات الحقيقية بالمؤقتة.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const TalbatiykApp(),
      ),
    );

    // تنفيذ أول دورة بناء للواجهة.
    await tester.pump();

    // التأكد من وجود التطبيق داخل شجرة الواجهات.
    expect(find.byType(TalbatiykApp), findsOneWidget);

    // إزالة التطبيق لإنهاء المؤقتات والعمليات المرتبطة بالواجهة.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

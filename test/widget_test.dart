import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/main.dart';

void main() {
  testWidgets('Talbatiyk app starts successfully', (WidgetTester tester) async {
    /// ننشئ قاعدة مؤقتة داخل الذاكرة حتى لا يستخدم الاختبار
    /// ملف قاعدة البيانات الحقيقي الموجود على جهاز المستخدم.
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    /// نغلق القاعدة المؤقتة بعد انتهاء الاختبار.
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          /// نستبدل قاعدة التطبيق الحقيقية بالقاعدة المؤقتة داخل الاختبار.
          appDatabaseProvider.overrideWithValue(database),
        ],
        child: const TalbatiykApp(),
      ),
    );

    await tester.pump();

    expect(find.byType(TalbatiykApp), findsOneWidget);

    /// نزيل التطبيق من شجرة الاختبار لإلغاء المؤقتات الموجودة في الواجهة.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

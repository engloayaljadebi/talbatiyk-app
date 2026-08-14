/*
|--------------------------------------------------------------------------
| Talbatiyk App Widget Test
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - التحقق من أن تطبيق طلبيتك يبدأ بدون أخطاء.
| - استخدام قاعدة بيانات مؤقتة داخل الذاكرة.
| - استخدام API Client بعنوان اختباري.
| - استخدام Secure Storage وهمي.
| - منع الاختبار من التعامل مع خدمات الجهاز الحقيقية.
|
*/

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/app.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk/core/network/network_providers.dart';
import 'package:talbatiyk/features/auth/data/datasources/local/auth_token_storage.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('Talbatiyk app starts successfully', (WidgetTester tester) async {
    // قاعدة بيانات مؤقتة لا تلمس بيانات الجهاز.
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);

    // تخزين آمن وهمي لا يستخدم Platform Channels.
    final secureStorage = FakeSecureKeyValueStore();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),

          /*
             * عنوان API اختباري.
             *
             * لن يتم إجراء طلب HTTP لأن التخزين
             * لا يحتوي على Access Token.
             */
          generatedApiClientProvider.overrideWithValue(
            GeneratedApiClient.create(baseUrl: 'http://127.0.0.1:8000/api/v1'),
          ),

          secureKeyValueStoreProvider.overrideWithValue(secureStorage),
        ],
        child: const TalbatiykApp(),
      ),
    );

    /*
       * إعطاء restoreSession فرصة لقراءة التخزين
       * والانتقال إلى unauthenticated.
       */
    await tester.pump();

    expect(find.byType(TalbatiykApp), findsOneWidget);

    // إزالة التطبيق وإنهاء الموارد المرتبطة بالواجهة.
    await tester.pumpWidget(const SizedBox.shrink());
  });
}

/// Secure Storage وهمي لاختبارات الواجهة.
final class FakeSecureKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write({required String key, required String value}) async {
    _values[key] = value;
  }

  @override
  Future<String?> read({required String key}) async {
    return _values[key];
  }

  @override
  Future<void> delete({required String key}) async {
    _values.remove(key);
  }

  @override
  Future<bool> containsKey({required String key}) async {
    return _values.containsKey(key);
  }
}

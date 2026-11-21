/*
|--------------------------------------------------------------------------
| API Environment
|--------------------------------------------------------------------------
|
| مسؤوليات الملف:
| - قراءة عنوان Laravel API من --dart-define.
| - منع الاعتماد على localhost المولد داخل OpenAPI Client.
| - التحقق من صلاحية عنوان API قبل إنشاء عميل الشبكة.
| - حصر نسخة Release بعنوان الإنتاج أو خادم Render عند تفعيل الاختبار الداخلي.
|
| مثال التطوير:
| flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
|
| مثال Production:
| flutter build appbundle --release --dart-define=API_BASE_URL=https://api.talbytk.com/api/v1
|
*/

import 'package:flutter/foundation.dart';

abstract final class ApiEnvironment {
  /// اسم المتغير الذي يمرر وقت التشغيل أو البناء.
  static const String _environmentKey = 'API_BASE_URL';

  static const bool isInternalTest = bool.fromEnvironment('INTERNAL_TEST_API');

  /// عنوان Production الرسمي المعتمد للتطبيق.
  static const String productionBaseUrl = 'https://api.talbytk.com/api/v1';

  /// عنوان API الذي يتم تمريره أثناء تشغيل أو بناء التطبيق.
  static const String _configuredBaseUrl = String.fromEnvironment(
    _environmentKey,
  );

  /// يعيد عنوان API الفعلي بعد التحقق منه.
  ///
  static String get baseUrl {
    return normalizeBaseUrl(
      _configuredBaseUrl,
      isRelease: kReleaseMode,
      allowInternalTest: isInternalTest,
    );
  }

  /// يتحقق من عنوان API وينظفه.
  ///
  /// فصل هذه الدالة عن [baseUrl] يجعل قواعد البيئة قابلة للاختبار
  /// بدون الاعتماد على compile-time dart-defines داخل الاختبارات.
  static String normalizeBaseUrl(
    String rawValue, {
    required bool isRelease,
    bool allowInternalTest = false,
  }) {
    final value = rawValue.trim();

    if (value.isEmpty) {
      throw StateError(
        '$_environmentKey غير محدد. '
        'مرّر عنوان API باستخدام '
        '--dart-define=$_environmentKey=http://HOST:PORT/api/v1',
      );
    }

    final normalized = value.replaceFirst(RegExp(r'/+$'), '');
    final uri = Uri.tryParse(normalized);

    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      throw StateError(
        '$_environmentKey يجب أن يكون عنوان HTTP أو HTTPS صالحًا.',
      );
    }

    if (allowInternalTest) {
      final renderHost = RegExp(
        r'^[a-z0-9](?:[a-z0-9-]*[a-z0-9])?\.onrender\.com$',
      );
      if (uri.scheme != 'https' ||
          !renderHost.hasMatch(uri.host) ||
          uri.authority != uri.host ||
          uri.path != '/api/v1' ||
          uri.hasQuery ||
          uri.hasFragment) {
        throw StateError(
          'الاختبار الداخلي يتطلب عنوان Render عبر HTTPS ينتهي بـ /api/v1.',
        );
      }
    } else if (isRelease && normalized != productionBaseUrl) {
      throw StateError(
        'نسخة Release يجب أن تستخدم عنوان Production المعتمد: '
        '$productionBaseUrl',
      );
    }

    return normalized;
  }
}

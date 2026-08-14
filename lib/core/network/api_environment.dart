/*
|--------------------------------------------------------------------------
| API Environment
|--------------------------------------------------------------------------
|
| مسؤوليات الملف:
| - قراءة عنوان Laravel API من --dart-define.
| - منع الاعتماد على localhost المولد داخل OpenAPI Client.
| - تنظيف الشرطة المائلة الأخيرة من Base URL.
|
| مثال التشغيل:
| flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
|
*/

abstract final class ApiEnvironment {
  /// عنوان الـ API الذي يتم تمريره أثناء تشغيل أو بناء التطبيق.
  static const String _configuredBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
  );

  /// يعيد عنوان الـ API بعد التحقق منه وتنظيفه.
  static String get baseUrl {
    final value = _configuredBaseUrl.trim();

    if (value.isEmpty) {
      throw StateError(
        'API_BASE_URL غير محدد. '
        'شغّل التطبيق باستخدام '
        '--dart-define=API_BASE_URL=http://HOST:PORT/api/v1',
      );
    }

    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }

    return value;
  }
}

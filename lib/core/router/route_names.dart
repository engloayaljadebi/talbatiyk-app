// محتوى الملف:
// - تجميع أسماء مسارات التطبيق في مكان مركزي.
// - منع كتابة المسارات النصية بصورة متكررة داخل الصفحات.

/// أسماء المسارات المعتمدة داخل تطبيق طلبيتك.
abstract final class RouteNames {
  /// الصفحة الرئيسية التي تحتوي أقسام التطبيق الخمسة.
  static const String main = '/';

  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String settings = '/settings';
}

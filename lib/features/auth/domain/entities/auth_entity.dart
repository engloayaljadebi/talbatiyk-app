/*
|--------------------------------------------------------------------------
| Auth Entities
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - AuthContactEntity لبيانات وسائل تواصل المستخدم.
| - AuthUserEntity لبيانات المستخدم داخل Domain.
| - AuthSessionEntity لتمثيل جلسة المستخدم داخل التطبيق.
|
| قواعد التصميم:
| - لا يعتمد الملف على OpenAPI أو Laravel أو Dio.
| - لا يحتوي على Access Token.
| - التواريخ تستخدم DateTime بدل String.
| - Access Token يبقى داخل Data Layer وSecure Storage فقط.
|
*/

/// وسيلة تواصل مرتبطة بالمستخدم.
final class AuthContactEntity {
  const AuthContactEntity({
    required this.id,
    required this.type,
    required this.value,
    required this.isPrimary,
    required this.verifiedAt,
  });

  /// المعرف العالمي لوسيلة التواصل.
  final String id;

  /// نوع وسيلة التواصل، مثل email أو phone.
  final String type;

  /// القيمة الفعلية لوسيلة التواصل.
  final String value;

  /// هل هذه وسيلة التواصل الأساسية من نوعها؟
  final bool isPrimary;

  /// تاريخ توثيق وسيلة التواصل إن كانت موثقة.
  final DateTime? verifiedAt;
}

/// المستخدم كما تفهمه طبقة Domain داخل التطبيق.
final class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.status,
    required this.lastLoginAt,
    required this.contacts,
  });

  /// UUID الخاص بالمستخدم.
  final String id;

  /// اسم تسجيل الدخول.
  final String username;

  /// الاسم الظاهر للمستخدم.
  final String displayName;

  /// حالة الحساب القادمة من النظام.
  final String status;

  /// آخر تسجيل دخول ناجح.
  final DateTime? lastLoginAt;

  /// وسائل التواصل المرتبطة بالمستخدم.
  final List<AuthContactEntity> contacts;

  /// هل الحساب في الحالة النشطة؟
  bool get isActive => status == 'active';
}

/// الجلسة المنطقية للمستخدم داخل التطبيق.
///
/// لا تحتوي على Access Token؛ لأن التوكن تفصيل أمني خاص
/// بطبقة Data ويتم حفظه داخل Secure Storage.
final class AuthSessionEntity {
  const AuthSessionEntity({required this.user});

  /// المستخدم المرتبط بالجلسة الحالية.
  final AuthUserEntity user;
}

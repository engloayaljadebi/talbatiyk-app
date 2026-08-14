/*
|--------------------------------------------------------------------------
| Auth State
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تعريف حالات المصادقة داخل واجهة التطبيق.
| - الاحتفاظ بالجلسة الحالية عند تسجيل الدخول.
| - الاحتفاظ برسالة الخطأ عند فشل عملية المصادقة.
| - توفير خصائص مساعدة لمعرفة حالة المستخدم.
|
| ملاحظة:
| هذا الملف لا يعرف Laravel أو Dio أو Secure Storage.
| ولا يحتوي على Access Token.
|
*/

import '../../domain/entities/auth_entity.dart';

/// المراحل التي تمر بها جلسة المصادقة داخل الواجهة.
enum AuthStatus {
  /// لم تبدأ عملية فحص الجلسة بعد.
  initial,

  /// جاري استعادة الجلسة المحفوظة عند تشغيل التطبيق.
  restoring,

  /// لا توجد جلسة مستخدم صالحة.
  unauthenticated,

  /// جاري تنفيذ تسجيل الدخول.
  authenticating,

  /// توجد جلسة مستخدم صالحة.
  authenticated,

  /// جاري تنفيذ تسجيل الخروج.
  signingOut,

  /// حدث خطأ أثناء إحدى عمليات المصادقة.
  failure,
}

/// الحالة التي تعتمد عليها واجهات المصادقة.
final class AuthState {
  const AuthState({
    this.status = AuthStatus.initial,
    this.session,
    this.errorMessage,
  });

  /// المرحلة الحالية للمصادقة.
  final AuthStatus status;

  /// جلسة المستخدم الحالية.
  ///
  /// تكون null عندما لا توجد جلسة مصادق عليها.
  final AuthSessionEntity? session;

  /// رسالة مناسبة للواجهة عند حدوث خطأ.
  final String? errorMessage;

  /// المستخدم الحالي إذا وجدت جلسة.
  AuthUserEntity? get user => session?.user;

  /// هل المستخدم مسجل الدخول حاليًا؟
  bool get isAuthenticated {
    return status == AuthStatus.authenticated && session != null;
  }

  /// هل التطبيق ينفذ عملية مصادقة حاليًا؟
  bool get isBusy {
    return status == AuthStatus.restoring ||
        status == AuthStatus.authenticating ||
        status == AuthStatus.signingOut;
  }

  /// إنشاء نسخة جديدة من الحالة مع تغيير القيم المطلوبة فقط.
  AuthState copyWith({
    AuthStatus? status,
    AuthSessionEntity? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

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
    this.isRegistering = false,
    this.registrationErrorMessage,
    this.registrationFieldErrors = const <String, String>{},
  });

  /// المرحلة الحالية للمصادقة.
  final AuthStatus status;

  /// جلسة المستخدم الحالية.
  ///
  /// تكون null عندما لا توجد جلسة مصادق عليها.
  final AuthSessionEntity? session;

  /// رسالة مناسبة للواجهة عند حدوث خطأ.
  final String? errorMessage;

  final bool isRegistering;
  final String? registrationErrorMessage;
  final Map<String, String> registrationFieldErrors;

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
        status == AuthStatus.signingOut ||
        isRegistering;
  }

  /// إنشاء نسخة جديدة من الحالة مع تغيير القيم المطلوبة فقط.
  AuthState copyWith({
    AuthStatus? status,
    AuthSessionEntity? session,
    bool clearSession = false,
    String? errorMessage,
    bool clearErrorMessage = false,
    bool? isRegistering,
    String? registrationErrorMessage,
    bool clearRegistrationErrorMessage = false,
    Map<String, String>? registrationFieldErrors,
    bool clearRegistrationFieldErrors = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: clearSession ? null : session ?? this.session,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      isRegistering: isRegistering ?? this.isRegistering,
      registrationFieldErrors: clearRegistrationFieldErrors
          ? const <String, String>{}
          : registrationFieldErrors ?? this.registrationFieldErrors,
      registrationErrorMessage: clearRegistrationErrorMessage
          ? null
          : registrationErrorMessage ?? this.registrationErrorMessage,
    );
  }
}

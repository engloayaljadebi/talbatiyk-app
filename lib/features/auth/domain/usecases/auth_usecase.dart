/*
|--------------------------------------------------------------------------
| Auth Use Case
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تسجيل الدخول بعد التحقق من البيانات.
| - استعادة الجلسة المحفوظة.
| - جلب بيانات المستخدم الحالي.
| - تسجيل الخروج.
|
| قواعد التصميم:
| - لا يعرف هذا الملف Laravel أو Dio أو OpenAPI.
| - لا يعرف Secure Storage.
| - يتعامل فقط مع AuthRepository وDomain Entities.
|
*/

import '../entities/auth_entity.dart';
import '../repositories/auth_repository.dart';

/// يحتوي على عمليات المصادقة وقواعد التحقق الأساسية.
final class AuthUseCase {
  AuthUseCase(this.repository);

  final AuthRepository repository;

  /// يسجل دخول المستخدم بعد التحقق من البيانات.
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) {
    final normalizedLogin = login.trim();
    final normalizedDeviceName = deviceName.trim();

    if (normalizedLogin.isEmpty) {
      throw ArgumentError('اسم المستخدم أو وسيلة تسجيل الدخول مطلوبة.');
    }

    /*
     * لا نقوم بعمل trim لكلمة المرور.
     *
     * المسافات قد تكون جزءًا حقيقيًا من كلمة المرور،
     * لذلك يجب إرسالها إلى الخادم كما كتبها المستخدم.
     */
    if (password.isEmpty) {
      throw ArgumentError('كلمة المرور مطلوبة.');
    }

    if (normalizedDeviceName.isEmpty) {
      throw ArgumentError('اسم الجهاز مطلوب.');
    }

    return repository.login(
      login: normalizedLogin,
      password: password,
      deviceName: normalizedDeviceName,
    );
  }

  /// يحاول استعادة جلسة المستخدم المحفوظة.
  Future<AuthSessionEntity?> restoreSession() {
    return repository.restoreSession();
  }

  /// يجلب أحدث بيانات المستخدم الحالي.
  Future<AuthUserEntity> getCurrentUser() {
    return repository.getCurrentUser();
  }

  /// يسجل خروج المستخدم من الجهاز الحالي.
  Future<void> logout() {
    return repository.logout();
  }
}

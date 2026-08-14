/*
|--------------------------------------------------------------------------
| Auth Repository
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تعريف عقد المصادقة الذي تستخدمه طبقة Domain.
| - تسجيل الدخول.
| - استعادة الجلسة المحفوظة عند تشغيل التطبيق.
| - جلب المستخدم الحالي.
| - تسجيل الخروج.
|
| قواعد التصميم:
| - لا يعرف هذا الملف Dio أو OpenAPI.
| - لا يعرف Secure Storage.
| - لا يتعامل مع Access Token مباشرة.
|
*/

import '../entities/auth_entity.dart';

/// العقد الذي تستخدمه طبقة الأعمال للتعامل مع المصادقة.
///
/// التنفيذ الفعلي هو المسؤول عن التنسيق بين:
/// - Laravel API.
/// - Secure Token Storage.
/// - Generated OpenAPI Client.
abstract class AuthRepository {
  /// يسجل دخول المستخدم ويعيد الجلسة بعد نجاح المصادقة.
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  });

  /// يحاول استعادة الجلسة المحفوظة عند تشغيل التطبيق.
  ///
  /// يعيد null عندما لا يوجد Access Token محفوظ.
  Future<AuthSessionEntity?> restoreSession();

  /// يجلب أحدث بيانات المستخدم الحالي من الخادم.
  Future<AuthUserEntity> getCurrentUser();

  /// يسجل الخروج ويلغي الجلسة المحفوظة.
  Future<void> logout();
}

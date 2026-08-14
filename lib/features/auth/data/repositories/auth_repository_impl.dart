/*
|--------------------------------------------------------------------------
| Auth Repository Implementation
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تنفيذ عقد AuthRepository.
| - التنسيق بين Laravel Remote API وSecure Token Storage.
| - تحويل OpenAPI Models إلى Domain Entities.
| - حفظ Access Token بعد تسجيل الدخول.
| - استعادة الجلسة المحفوظة عند تشغيل التطبيق.
| - تنظيف بيانات الجلسة عند تسجيل الخروج.
|
| قواعد التصميم:
| - Domain لا يعرف OpenAPI أو Dio أو Secure Storage.
| - Access Token لا يغادر طبقة Data.
| - فشل الاتصال أثناء استعادة الجلسة لا يحذف Token المحفوظ تلقائيًا.
| - 401 فقط يعني أن الجلسة لم تعد صالحة ويجب حذف Token المحلي.
|
*/

import 'package:dio/dio.dart';

import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_token_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../mappers/auth_mapper.dart';

/// تنفيذ مستودع المصادقة.
///
/// يجمع بين:
/// - مصدر المصادقة البعيد.
/// - التخزين الآمن للتوكن.
/// - Mapper الخاص بتحويل Models إلى Domain Entities.
final class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this._remoteDataSource,
    required this._tokenStorage,
  });

  final AuthRemoteDataSource _remoteDataSource;
  final AuthTokenStorage _tokenStorage;

  @override
  Future<AuthSessionEntity> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    /*
     * نطلب تسجيل الدخول من Laravel أولًا.
     *
     * AuthRemoteDataSource سيضع Bearer Token
     * مباشرة داخل Generated API Client بعد نجاح الطلب.
     */
    final remoteSession = await _remoteDataSource.login(
      login: login,
      password: password,
      deviceName: deviceName,
    );

    try {
      /*
       * نحفظ Access Token في Secure Storage
       * حتى نستطيع استعادة الجلسة بعد إغلاق التطبيق.
       */
      await _tokenStorage.saveAccessToken(remoteSession.accessToken);
    } catch (error, stackTrace) {
      /*
       * Laravel أنشأ Token بنجاح، لكن حفظه محليًا فشل.
       *
       * نحاول إلغاء Token من Laravel حتى لا نترك
       * جلسة غير قابلة للإدارة على الخادم.
       */
      try {
        await _remoteDataSource.logout();
      } catch (_) {
        /*
         * إذا تعذر الوصول إلى Laravel أيضًا،
         * ننظف على الأقل Bearer Token من ذاكرة العميل.
         */
        _remoteDataSource.clearAccessToken();
      }

      /*
       * نعيد نفس الخطأ الأصلي مع StackTrace الأصلي.
       */
      Error.throwWithStackTrace(error, stackTrace);
    }

    /*
     * Access Token لا يخرج إلى Domain.
     * Mapper يعيد AuthSessionEntity الذي يحتوي المستخدم فقط.
     */
    return remoteSession.toDomain();
  }

  @override
  Future<AuthSessionEntity?> restoreSession() async {
    /*
     * نقرأ Access Token المحفوظ على الجهاز.
     */
    final accessToken = await _tokenStorage.readAccessToken();

    /*
     * لا يوجد Token محفوظ، إذًا لا توجد جلسة.
     */
    if (accessToken == null) {
      return null;
    }

    /*
     * نعيد Bearer Token إلى Generated API Client
     * حتى يستخدمه في الطلبات المحمية.
     */
    _remoteDataSource.setAccessToken(accessToken);

    try {
      /*
       * لا نعتبر وجود Token محلي دليلًا كافيًا
       * على أن الجلسة ما زالت صالحة.
       *
       * نتحقق فعليًا من Laravel عبر:
       *
       * GET /api/v1/auth/me
       */
      final user = await _remoteDataSource.me();

      /*
       * Laravel قبل Token وأعاد المستخدم الحالي.
       * إذًا الجلسة صالحة.
       */
      return AuthSessionEntity(user: user.toDomain());
    } on DioException catch (error) {
      /*
       * 401 Unauthorized يعني أن Token المحفوظ
       * لم يعد صالحًا على Laravel.
       *
       * أمثلة:
       * - تم إلغاء Token من الخادم.
       * - انتهت صلاحية Token مستقبلًا.
       * - تم حذف الجلسة من Sanctum.
       */
      if (error.response?.statusCode == 401) {
        /*
         * ننظف Bearer Token من ذاكرة العميل أولًا.
         */
        _remoteDataSource.clearAccessToken();

        /*
         * ثم نحذف Token نهائيًا من Secure Storage.
         */
        await _tokenStorage.deleteAccessToken();

        /*
         * null تخبر AuthController أنه لا توجد جلسة صالحة،
         * وبالتالي GoRouter سينقل المستخدم إلى LoginPage.
         */
        return null;
      }

      /*
       * لا نحذف Token عند:
       * - انقطاع الإنترنت.
       * - Timeout.
       * - Connection Error.
       * - أخطاء Laravel 5xx.
       *
       * لأن الجلسة قد تكون ما زالت صالحة،
       * والمشكلة مؤقتة في الشبكة أو الخادم.
       */
      rethrow;
    }
  }

  @override
  Future<AuthUserEntity> getCurrentUser() async {
    /*
     * جلب بيانات المستخدم الحالي من Laravel.
     */
    final user = await _remoteDataSource.me();

    return user.toDomain();
  }

  @override
  Future<void> logout() async {
    /*
     * نحاول أولًا إلغاء Sanctum Token على Laravel.
     *
     * finally متعمد:
     * حتى لو كان الجهاز بلا إنترنت أو Laravel غير متاح،
     * يجب أن يستطيع المستخدم تسجيل الخروج من الجهاز.
     */
    try {
      await _remoteDataSource.logout();
    } finally {
      /*
       * إزالة Bearer Token من ذاكرة Generated API Client.
       */
      _remoteDataSource.clearAccessToken();

      /*
       * حذف Access Token من Secure Storage.
       */
      await _tokenStorage.deleteAccessToken();
    }
  }
}

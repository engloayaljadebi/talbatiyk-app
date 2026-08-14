/*
|--------------------------------------------------------------------------
| Auth Remote Data Source
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تعريف عقد مصدر بيانات المصادقة البعيد.
| - تسجيل الدخول عبر Generated OpenAPI Client.
| - جلب بيانات المستخدم الحالي.
| - تسجيل الخروج من الجهاز الحالي.
| - ربط Sanctum Bearer Token بالعميل.
| - إزالة Bearer Token من العميل.
|
| ملاحظة:
| الأنواع المولدة من OpenAPI تبقى داخل طبقة Data ولا تصل مباشرة
| إلى Presentation أو Domain.
|
*/

import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

/// العقد المسؤول عن عمليات المصادقة البعيدة.
abstract interface class AuthRemoteDataSource {
  /// يسجل دخول المستخدم ويعيد بيانات جلسة الدخول.
  Future<AuthRegister201ResponseData> login({
    required String login,
    required String password,
    required String deviceName,
  });

  /// يجلب بيانات المستخدم الحالي باستخدام Bearer Token.
  Future<UserResource> me();

  /// يسجل خروج الجهاز الحالي من الخادم.
  Future<void> logout();

  /// يربط Access Token بالعميل للطلبات المحمية.
  void setAccessToken(String token);

  /// يزيل Access Token من العميل.
  void clearAccessToken();
}

/// تنفيذ المصادقة باستخدام العميل المولد من OpenAPI.
final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<AuthRegister201ResponseData> login({
    required String login,
    required String password,
    required String deviceName,
  }) async {
    final request = LoginRequest(
      (builder) => builder
        ..login = login
        ..password = password
        ..deviceName = deviceName,
    );

    final response = await _apiClient.auth.authLogin(loginRequest: request);

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة تسجيل الدخول لا تحتوي على بيانات.');
    }

    final session = responseBody.data;

    // تسجيل الدخول الناجح يجعل العميل جاهزًا
    // مباشرة للطلبات المحمية التالية.
    setAccessToken(session.accessToken);

    return session;
  }

  @override
  Future<UserResource> me() async {
    final response = await _apiClient.auth.authMe();

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة بيانات المستخدم لا تحتوي على بيانات.');
    }

    return responseBody.data;
  }

  @override
  Future<void> logout() async {
    // إلغاء التوكن في Laravel أولًا.
    await _apiClient.auth.authLogout();

    // ثم تنظيف التوكن من العميل المحلي.
    clearAccessToken();
  }

  @override
  void setAccessToken(String token) {
    final normalizedToken = token.trim();

    if (normalizedToken.isEmpty) {
      throw ArgumentError.value(
        token,
        'token',
        'لا يمكن استخدام Access Token فارغ.',
      );
    }

    _apiClient.setAccessToken(normalizedToken);
  }

  @override
  void clearAccessToken() {
    _apiClient.clearAccessToken();
  }
}

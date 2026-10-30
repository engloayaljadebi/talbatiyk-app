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

import 'package:dio/dio.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

/// Approval state returned without exposing generated SDK models.
typedef BusinessApprovalSnapshot = ({
  String businessId,
  String? shopStatus,
  String? supplierStatus,
  bool supplierEnabled,
});

/// Reads approval states through the generated authenticated API.
Future<List<BusinessApprovalSnapshot>> fetchBusinessApprovals(
  GeneratedApiClient apiClient,
) async {
  final authExtra = apiClient.captureProtectedRequestAuthExtra();

  final response = await apiClient.auth.authBusinessApprovals(extra: authExtra);

  apiClient.ensureProtectedRequestAuthCurrent(authExtra);

  final body = response.data;

  if (body == null) {
    throw StateError('استجابة حالات اعتماد الأنشطة فارغة.');
  }

  return body.data
      .map(
        (item) => (
          businessId: item.businessId,
          shopStatus: item.shopStatus,
          supplierStatus: item.supplierStatus,
          supplierEnabled: item.supplierEnabled,
        ),
      )
      .toList(growable: false);
}

/// العقد المسؤول عن عمليات المصادقة البعيدة.
abstract interface class AuthRemoteDataSource {
  Future<List<({String id, String name})>> fetchRegistrationCategories();

  Future<AuthRegister201ResponseData> registerFromMobile(
    Map<String, Object?> payload,
  );

  /// يسجل دخول المستخدم ويعيد بيانات جلسة الدخول.
  Future<AuthLogin200ResponseData> login({
    required String login,
    required String password,
    required String deviceName,
  });

  /// يجلب بيانات المستخدم الحالي باستخدام Bearer Token.
  Future<UserResource> me();

  /// يحدّث هوية الملف الشخصي للمستخدم الحالي.
  Future<UserResource> updateProfile({String? username, String? displayName});

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
  Future<AuthLogin200ResponseData> login({
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

  /// Fetch active leaf categories without an authenticated session.
  @override
  Future<List<({String id, String name})>> fetchRegistrationCategories() async {
    final response = await _apiClient.auth.authRegistrationCategories();
    final body = response.data;

    if (body == null) {
      throw StateError('استجابة فئات التسجيل فارغة.');
    }

    return body.data
        .map((item) => (id: item.id, name: item.name))
        .toList(growable: false);
  }

  /// Submit mobile registration using the existing configured API client.
  /// The generated contact_value union is sent as ordinary JSON.
  @override
  Future<AuthRegister201ResponseData> registerFromMobile(
    Map<String, Object?> payload,
  ) async {
    final response = await _apiClient.client.dio.post<Object?>(
      '/auth/register',
      data: payload,
      options: Options(
        contentType: Headers.jsonContentType,
        headers: <String, String>{'Accept': 'application/json'},
      ),
    );

    final parsed = _apiClient.client.serializers.deserializeWith(
      AuthRegister201Response.serializer,
      response.data,
    );

    if (parsed == null) {
      throw StateError('استجابة إنشاء الحساب فارغة أو غير صالحة.');
    }

    final session = parsed.data;

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
  Future<UserResource> updateProfile({
    String? username,
    String? displayName,
  }) async {
    final request = UpdateProfileRequest((builder) {
      if (username != null) {
        builder.username = username;
      }

      if (displayName != null) {
        builder.displayName = displayName;
      }
    });

    final response = await _apiClient.auth.authUpdateProfile(
      updateProfileRequest: request,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة تحديث بيانات المستخدم لا تحتوي على بيانات.');
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

/*
|--------------------------------------------------------------------------
| Generated API Client
|--------------------------------------------------------------------------
|
| مسؤوليات الملف:
| - إنشاء TalbatiykApi المولد من OpenAPI.
| - تمرير Base URL الخاص بالبيئة الحالية.
| - تفعيل وإزالة Sanctum Bearer Token.
| - توفير نقاط الوصول للـ APIs المولدة.
|
| ملاحظة:
| لا نعدل أي ملف داخل packages/talbatiyk_api يدويًا.
|
*/

import 'package:talbatiyk_api/talbatiyk_api.dart';

import 'api_environment.dart';

final class GeneratedApiClient {
  GeneratedApiClient._(this.client);

  /// اسم مخطط Bearer Security كما هو معرف في OpenAPI.
  static const String _bearerSecurityName = 'http';

  /// العميل المولد من عقد OpenAPI.
  final TalbatiykApi client;

  /// ينشئ عميل API باستخدام عنوان البيئة الحالية.
  factory GeneratedApiClient.create({String? baseUrl}) {
    return GeneratedApiClient._(
      TalbatiykApi(basePathOverride: baseUrl ?? ApiEnvironment.baseUrl),
    );
  }

  /// Auth endpoints.
  AuthApi get auth => client.getAuthApi();

  /// Business endpoints.
  BusinessApi get businesses => client.getBusinessApi();

  /// Business locations endpoints.
  BusinessLocationApi get businessLocations => client.getBusinessLocationApi();

  /// Business contacts endpoints.
  BusinessContactApi get businessContacts => client.getBusinessContactApi();

  /// يربط Sanctum Personal Access Token بالطلبات المحمية.
  void setAccessToken(String token) {
    client.setBearerAuth(_bearerSecurityName, token);
  }

  /// يزيل التوكن من العميل، مثلًا بعد تسجيل الخروج.
  void clearAccessToken() {
    client.removeBearerAuth(_bearerSecurityName);
  }
}

/*
|--------------------------------------------------------------------------
| Generated API Client
|--------------------------------------------------------------------------
|
| المسؤوليات:
| - إنشاء TalbatiykApi المولد من OpenAPI.
| - تمرير Base URL الخاص بالبيئة الحالية.
| - تفعيل وإزالة Sanctum Bearer Token.
| - توفير نقاط الوصول للـ APIs المولدة.
| - دعم طلبات JSON الخام الموثقة للحالات التي لا يستطيع
|   Generated DTO تمثيلها بدقة، مثل PATCH tri-state.
|
| قواعد الأمان:
| - التوكن لا يخرج خارج هذه الطبقة.
| - أي Raw authenticated request يفشل مغلقًا إذا لم توجد جلسة.
| - لا يتم تعديل الملفات المولدة داخل packages/talbatiyk_api.
|
*/

import 'package:dio/dio.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

import 'api_environment.dart';

final class GeneratedApiClient {
  GeneratedApiClient._(this.client);

  static const String _bearerSecurityName = 'http';

  final TalbatiykApi client;

  String? _accessToken;

  factory GeneratedApiClient.create({String? baseUrl}) {
    return GeneratedApiClient._(
      TalbatiykApi(basePathOverride: baseUrl ?? ApiEnvironment.baseUrl),
    );
  }

  AuthApi get auth => client.getAuthApi();

  BusinessApi get businesses => client.getBusinessApi();

  BusinessLocationApi get businessLocations => client.getBusinessLocationApi();

  BusinessContactApi get businessContacts => client.getBusinessContactApi();

  ProductApi get products => client.getProductApi();

  NotificationApi get notifications => client.getNotificationApi();

  OrderApi get orders => client.getOrderApi();

  SupplierDiscoveryApi get supplierDiscovery =>
      client.getSupplierDiscoveryApi();

  SupplierFollowApi get supplierFollow => client.getSupplierFollowApi();

  SupplierOrderApi get supplierOrders => client.getSupplierOrderApi();

  SupplierOrderResponseApi get supplierOrderResponses =>
      client.getSupplierOrderResponseApi();

  SupplierOrderFulfillmentApi get supplierOrderFulfillment =>
      client.getSupplierOrderFulfillmentApi();

  OrderResponseComparisonApi get orderResponseComparisons =>
      client.getOrderResponseComparisonApi();

  void setAccessToken(String token) {
    final normalized = token.trim();

    if (normalized.isEmpty) {
      throw ArgumentError.value(
        token,
        'token',
        'Access token cannot be empty.',
      );
    }

    _accessToken = normalized;

    client.setBearerAuth(_bearerSecurityName, normalized);
  }

  void clearAccessToken() {
    _accessToken = null;

    client.removeBearerAuth(_bearerSecurityName);
  }

  /// يستخدم فقط عندما لا يستطيع DTO المولد تمثيل JSON المطلوب بدقة.
  ///
  /// مثال:
  /// PATCH يحتاج التفريق بين:
  /// - absent
  /// - explicit null
  /// - value
  ///
  /// لا نكشف access token خارج هذه الطبقة.
  Future<Response<T>> patchJsonAuthenticated<T>({
    required String path,
    required Object? data,
  }) {
    final token = _accessToken;

    if (token == null || token.isEmpty) {
      throw StateError('Authenticated PATCH requires an active access token.');
    }

    return client.dio.patch<T>(
      path,
      data: data,
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        contentType: Headers.jsonContentType,
      ),
    );
  }
}

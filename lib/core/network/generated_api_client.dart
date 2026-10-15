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
  GeneratedApiClient._(this.client) {
    // The generated Bearer interceptor runs before this guard.
    // Reject an order whose auth generation changed while queued.
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (!options.extra.containsKey(_orderAuthRevisionExtraKey)) {
            handler.next(options);
            return;
          }

          final expected = options.extra[_orderAuthRevisionExtraKey];
          final token = _accessToken;

          if (expected is! int ||
              expected != _authRevision ||
              token == null ||
              token.isEmpty) {
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.cancel,
                error: StateError(
                  'Order authentication changed before dispatch.',
                ),
              ),
            );
            return;
          }

          // Bind the currently verified credential to this request.
          options.headers['Authorization'] = 'Bearer $token';
          handler.next(options);
        },
      ),
    );
  }

  static const String _bearerSecurityName = 'http';
  static const String _orderAuthRevisionExtraKey =
      '_talbatiykOrderAuthRevision';

  final TalbatiykApi client;

  String? _accessToken;
  int _authRevision = 0;

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
    _authRevision++;

    client.setBearerAuth(_bearerSecurityName, normalized);
  }

  void clearAccessToken() {
    _accessToken = null;
    _authRevision++;

    client.removeBearerAuth(_bearerSecurityName);
  }

  /// Capture the credential generation without exposing the access token.
  /// Called synchronously before constructing an order HTTP request.
  /// Captures the current authentication revision for a protected HTTP request.
  /// Contains no access token; an invalidated revision is rejected by Dio.
  Map<String, dynamic> captureProtectedRequestAuthExtra() =>
      captureOrderAuthExtra();

  /// Rejects results from an invalidated authentication revision.
  void ensureProtectedRequestAuthCurrent(Map<String, dynamic> captured) {
    final expectedRevision = captured[_orderAuthRevisionExtraKey];

    if (expectedRevision is! int ||
        expectedRevision != _authRevision ||
        _accessToken == null ||
        _accessToken!.isEmpty) {
      throw StateError('Authentication changed during the HTTP request.');
    }
  }

  Map<String, dynamic> captureOrderAuthExtra() {
    final token = _accessToken;
    if (token == null || token.isEmpty) {
      throw StateError('Authenticated order request requires a token.');
    }
    return <String, dynamic>{_orderAuthRevisionExtraKey: _authRevision};
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
  }) async {
    final token = _accessToken;

    if (token == null || token.isEmpty) {
      throw StateError('Authenticated PATCH requires an active access token.');
    }

    final authExtra = captureProtectedRequestAuthExtra();

    final response = await client.dio.patch<T>(
      path,
      data: data,
      options: Options(
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        contentType: Headers.jsonContentType,
        extra: authExtra,
      ),
    );

    ensureProtectedRequestAuthCurrent(authExtra);
    return response;
  }
}

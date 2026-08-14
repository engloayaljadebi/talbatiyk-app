/*
|--------------------------------------------------------------------------
| Business Remote Data Source
|--------------------------------------------------------------------------
|
| محتويات الملف:
| - تعريف عقد مصدر بيانات Business البعيد.
| - جلب الأنشطة المرتبطة بالمستخدم الحالي.
| - جلب نشاط واحد بواسطة ID.
| - إنشاء نشاط جديد عبر Generated OpenAPI Client.
|
| قواعد التصميم:
| - جميع الأنواع المولدة من OpenAPI تبقى داخل طبقة Data.
| - لا تصل BusinessResource أو CreateBusinessRequest إلى Domain/Presentation.
| - PATCH غير موجود هنا مؤقتًا لأنه يحتاج Raw JSON Bridge مستقل
|   للحفاظ على tri-state:
|   absent / null / value.
|
*/

import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

/// العقد المسؤول عن عمليات Business البعيدة.
abstract interface class BusinessRemoteDataSource {
  /// يجلب جميع الأنشطة التي يستطيع المستخدم الحالي الوصول إليها.
  Future<BuiltList<BusinessResource>> index();

  /// يجلب نشاطًا واحدًا بواسطة المعرف.
  Future<BusinessResource> show({required String businessId});

  /// ينشئ نشاطًا جديدًا.
  Future<BusinessResource> store({required CreateBusinessRequest request});
}

/// تنفيذ مصدر بيانات Business باستخدام Generated OpenAPI Client.
final class BusinessRemoteDataSourceImpl implements BusinessRemoteDataSource {
  BusinessRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<BuiltList<BusinessResource>> index() async {
    final response = await _apiClient.businesses.businessIndex();

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة قائمة الأنشطة لا تحتوي على بيانات.');
    }

    return responseBody.data;
  }

  @override
  Future<BusinessResource> show({required String businessId}) async {
    final normalizedBusinessId = businessId.trim();

    if (normalizedBusinessId.isEmpty) {
      throw ArgumentError.value(
        businessId,
        'businessId',
        'لا يمكن أن يكون معرف النشاط فارغًا.',
      );
    }

    final response = await _apiClient.businesses.businessShow(
      business: normalizedBusinessId,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة بيانات النشاط لا تحتوي على بيانات.');
    }

    return responseBody.data;
  }

  @override
  Future<BusinessResource> store({
    required CreateBusinessRequest request,
  }) async {
    final response = await _apiClient.businesses.businessStore(
      createBusinessRequest: request,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة إنشاء النشاط لا تحتوي على بيانات.');
    }

    return responseBody.data;
  }
}

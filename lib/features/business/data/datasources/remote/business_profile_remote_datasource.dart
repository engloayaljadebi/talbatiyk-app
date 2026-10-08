import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../../domain/entities/business_profile_update.dart';
import '../../mappers/business_profile_patch_mapper.dart';

abstract interface class BusinessProfileRemoteDataSource {
  Future<BusinessResource> updateProfile({
    required String businessId,
    required BusinessProfileUpdate update,
  });
}

final class BusinessProfileRemoteDataSourceImpl
    implements BusinessProfileRemoteDataSource {
  const BusinessProfileRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<BusinessResource> updateProfile({
    required String businessId,
    required BusinessProfileUpdate update,
  }) async {
    final normalizedId = businessId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        businessId,
        'businessId',
        'لا يمكن أن يكون معرف النشاط فارغًا.',
      );
    }

    if (update.isEmpty) {
      throw ArgumentError.value(update, 'update', 'لا توجد تغييرات لإرسالها.');
    }

    final payload = BusinessProfilePatchMapper.toJson(update);

    await _apiClient.patchJsonAuthenticated<Object?>(
      path: '/businesses/${Uri.encodeComponent(normalizedId)}',
      data: payload,
    );

    final response = await _apiClient.businesses.businessShow(
      business: normalizedId,
    );

    final responseBody = response.data;

    if (responseBody == null) {
      throw StateError('استجابة النشاط بعد التحديث لا تحتوي على بيانات.');
    }

    return responseBody.data;
  }
}

import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

abstract interface class SupplierFollowRemoteDataSource {
  Future<bool> isFollowing(String businessId);

  Future<bool> follow(String businessId);

  Future<bool> unfollow(String businessId);
}

final class SupplierFollowRemoteDataSourceImpl
    implements SupplierFollowRemoteDataSource {
  SupplierFollowRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<bool> isFollowing(String businessId) async {
    final response = await _apiClient.supplierFollow.supplierFollowShow(
      business: businessId,
    );

    return _readStatus(response.data, businessId);
  }

  @override
  Future<bool> follow(String businessId) async {
    final response = await _apiClient.supplierFollow.supplierFollowStore(
      business: businessId,
    );

    return _readStatus(response.data, businessId);
  }

  @override
  Future<bool> unfollow(String businessId) async {
    final response = await _apiClient.supplierFollow.supplierFollowDestroy(
      business: businessId,
    );

    return _readStatus(response.data, businessId);
  }

  bool _readStatus(
    SupplierFollowShow200Response? responseBody,
    String expectedBusinessId,
  ) {
    if (responseBody == null) {
      throw StateError('Supplier follow response does not contain data.');
    }

    final data = responseBody.data;

    // Reject mismatched server data instead of changing another supplier's UI.
    if (data.businessId != expectedBusinessId) {
      throw StateError(
        'Supplier follow response business does not match request.',
      );
    }

    return data.isFollowing;
  }
}

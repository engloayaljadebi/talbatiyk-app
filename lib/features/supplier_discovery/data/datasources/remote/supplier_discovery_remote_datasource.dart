import 'package:built_collection/built_collection.dart';
import 'package:talbatiyk/core/network/generated_api_client.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

abstract interface class SupplierDiscoveryRemoteDataSource {
  Future<BuiltList<SupplierSummaryResource>> index();
}

final class SupplierDiscoveryRemoteDataSourceImpl
    implements SupplierDiscoveryRemoteDataSource {
  const SupplierDiscoveryRemoteDataSourceImpl(this._apiClient);

  final GeneratedApiClient _apiClient;

  @override
  Future<BuiltList<SupplierSummaryResource>> index() async {
    final response = await _apiClient.supplierDiscovery
        .supplierDiscoveryIndex();

    final body = response.data;

    if (body == null) {
      throw StateError('Supplier discovery response does not contain data.');
    }

    return body.data;
  }
}

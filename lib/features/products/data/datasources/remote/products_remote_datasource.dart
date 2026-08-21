import 'package:talbatiyk/core/network/generated_api_client.dart';

import '../../mappers/products_mapper.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// Reads discoverable products from the generated OpenAPI client.
///
/// This source is intentionally read-only. Local product writes remain on the
/// existing local datasource until their dedicated synchronization gate.
final class ProductsRemoteDataSource implements ProductsDataSource {
  ProductsRemoteDataSource(this._apiClient);

  static const int _perPage = 100;

  final GeneratedApiClient _apiClient;

  @override
  Future<List<ProductModel>> getProducts() async {
    final productsById = <String, ProductModel>{};

    var page = 1;

    while (true) {
      final response = await _apiClient.products.productIndex(
        page: page,
        perPage: _perPage,
      );

      final responseBody = response.data;

      if (responseBody == null) {
        throw StateError('Product discovery response does not contain data.');
      }

      for (final resource in responseBody.data) {
        final product = ProductsMapper.fromResource(resource);
        productsById[product.id] = product;
      }

      if (page >= responseBody.meta.lastPage) {
        break;
      }

      page += 1;
    }

    return List<ProductModel>.unmodifiable(productsById.values);
  }
}

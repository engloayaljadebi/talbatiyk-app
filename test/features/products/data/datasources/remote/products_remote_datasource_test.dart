import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/network/api_client.dart';
import 'package:talbatiyk/features/products/data/datasources/remote/products_remote_datasource.dart';

void main() {
  group('ProductsRemoteDataSource', () {
    test('parses products from a nested API envelope', () async {
      final client = _FakeProductsApiClient({
        'data': {
          'products': [
            {
              'id': 'product-1',
              'name': 'سماعة',
              'price': 15000,
              'image_url': '',
              'category': 'سماعات',
              'brand': 'Apple',
              'is_available': true,
            },
          ],
        },
      });
      final dataSource = ProductsRemoteDataSource(client: client);

      final products = await dataSource.getProducts();

      expect(client.requestedPath, '/products');
      expect(products, hasLength(1));
      expect(products.single.id, 'product-1');
      expect(products.single.price, 15000);
    });

    test('rejects a response that has no products list', () async {
      final dataSource = ProductsRemoteDataSource(
        client: _FakeProductsApiClient({'data': {'message': 'ok'}}),
      );

      expect(dataSource.getProducts(), throwsFormatException);
    });
  });
}

class _FakeProductsApiClient implements ApiClient {
  _FakeProductsApiClient(this.response);

  final Object? response;
  String? requestedPath;

  @override
  Future<Object?> get(
    String path, {
    Map<String, Object?>? queryParameters,
  }) async {
    requestedPath = path;
    return response;
  }

  @override
  Future<Object?> post(
    String path, {
    Object? body,
    Map<String, Object?>? queryParameters,
  }) {
    throw UnsupportedError('POST is not used by this test.');
  }
}

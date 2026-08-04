import '../../dto/products_dto.dart';
import '../../mappers/products_mapper.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// Small transport contract that can later be implemented with Dio or http.
abstract interface class ProductsApiClient {
  Future<Object?> get(
    String path, {
    Map<String, Object?>? queryParameters,
  });
}

class ProductsRemoteDataSource implements ProductsDataSource {
  const ProductsRemoteDataSource({
    required this.client,
    this.endpoint = '/products',
  });

  final ProductsApiClient client;
  final String endpoint;

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(endpoint);
    final items = _extractItems(response);

    return List<ProductModel>.unmodifiable(
      items.map((item) {
        final dto = ProductDto.fromJson(_asJsonMap(item));
        return ProductsMapper.toModel(dto);
      }),
    );
  }

  List<Object?> _extractItems(Object? payload) {
    if (payload is List) {
      return payload.cast<Object?>();
    }

    if (payload is Map) {
      for (final key in const ['data', 'items', 'products']) {
        if (payload.containsKey(key)) {
          return _extractItems(payload[key]);
        }
      }
    }

    throw const FormatException(
      'Products response must contain a list of products.',
    );
  }

  Map<String, dynamic> _asJsonMap(Object? value) {
    if (value is! Map) {
      throw const FormatException('Each product must be a JSON object.');
    }

    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}

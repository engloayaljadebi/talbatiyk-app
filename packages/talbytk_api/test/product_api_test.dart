import 'package:test/test.dart';
import 'package:talbytk_api/talbytk_api.dart';


/// tests for ProductApi
void main() {
  final instance = TalbytkApi().getProductApi();

  group(ProductApi, () {
    //Future<ProductIndex200Response> productIndex({ int page, int perPage }) async
    test('test productIndex', () async {
      // TODO
    });

  });
}

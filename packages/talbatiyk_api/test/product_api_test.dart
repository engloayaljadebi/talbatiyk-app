import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for ProductApi
void main() {
  final instance = TalbatiykApi().getProductApi();

  group(ProductApi, () {
    //Future<ProductIndex200Response> productIndex({ int page, int perPage }) async
    test('test productIndex', () async {
      // TODO
    });

  });
}

import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for SupplierOrderApi
void main() {
  final instance = TalbatiykApi().getSupplierOrderApi();

  group(SupplierOrderApi, () {
    // List orders received by one supplier Business
    //
    //Future<SupplierOrderIndex200Response> supplierOrderIndex(String business) async
    test('test supplierOrderIndex', () async {
      // TODO
    });

  });
}

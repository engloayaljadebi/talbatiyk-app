import 'package:test/test.dart';
import 'package:talbytk_api/talbytk_api.dart';


/// tests for SupplierOrderApi
void main() {
  final instance = TalbytkApi().getSupplierOrderApi();

  group(SupplierOrderApi, () {
    // List orders received by one supplier Business
    //
    //Future<SupplierOrderIndex200Response> supplierOrderIndex(String business) async
    test('test supplierOrderIndex', () async {
      // TODO
    });

  });
}

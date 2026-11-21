import 'package:test/test.dart';
import 'package:talbytk_api/talbytk_api.dart';


/// tests for SupplierOrderResponseApi
void main() {
  final instance = TalbytkApi().getSupplierOrderResponseApi();

  group(SupplierOrderResponseApi, () {
    // Submit the final response for one supplier order recipient
    //
    //Future<SupplierOrderResponseStore201Response> supplierOrderResponseStore(String business, String recipient, String idempotencyKey, SubmitSupplierOrderResponseRequest submitSupplierOrderResponseRequest) async
    test('test supplierOrderResponseStore', () async {
      // TODO
    });

  });
}

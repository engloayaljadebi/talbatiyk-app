import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for SupplierOrderFulfillmentApi
void main() {
  final instance = TalbatiykApi().getSupplierOrderFulfillmentApi();

  group(SupplierOrderFulfillmentApi, () {
    // Advance one supplier Recipient through its fulfillment lifecycle
    //
    //Future<SupplierOrderFulfillmentUpdate200Response> supplierOrderFulfillmentUpdate(String business, String recipient, UpdateSupplierFulfillmentRequest updateSupplierFulfillmentRequest) async
    test('test supplierOrderFulfillmentUpdate', () async {
      // TODO
    });

  });
}

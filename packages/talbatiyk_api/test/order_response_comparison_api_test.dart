import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for OrderResponseComparisonApi
void main() {
  final instance = TalbatiykApi().getOrderResponseComparisonApi();

  group(OrderResponseComparisonApi, () {
    // Compare all final supplier responses for one owned Order
    //
    //Future<OrderResponseComparisonShow200Response> orderResponseComparisonShow(String order) async
    test('test orderResponseComparisonShow', () async {
      // TODO
    });

    // Replace the customer's supplier-response selection atomically
    //
    //Future<OrderResponseComparisonShow200Response> orderResponseComparisonUpdate(String order, SelectOrderSupplierResponsesRequest selectOrderSupplierResponsesRequest) async
    test('test orderResponseComparisonUpdate', () async {
      // TODO
    });

  });
}

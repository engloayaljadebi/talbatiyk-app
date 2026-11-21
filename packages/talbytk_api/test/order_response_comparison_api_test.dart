import 'package:test/test.dart';
import 'package:talbytk_api/talbytk_api.dart';


/// tests for OrderResponseComparisonApi
void main() {
  final instance = TalbytkApi().getOrderResponseComparisonApi();

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

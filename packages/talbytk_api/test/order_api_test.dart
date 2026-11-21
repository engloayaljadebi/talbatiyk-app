import 'package:test/test.dart';
import 'package:talbytk_api/talbytk_api.dart';


/// tests for OrderApi
void main() {
  final instance = TalbytkApi().getOrderApi();

  group(OrderApi, () {
    // Create a new order for the authenticated user
    //
    //Future<OrderStore201Response> orderStore(CreateOrderRequest createOrderRequest) async
    test('test orderStore', () async {
      // TODO
    });

  });
}

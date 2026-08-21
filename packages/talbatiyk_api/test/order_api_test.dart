import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for OrderApi
void main() {
  final instance = TalbatiykApi().getOrderApi();

  group(OrderApi, () {
    // Create a new order for the authenticated user
    //
    //Future<OrderStore201Response> orderStore(CreateOrderRequest createOrderRequest) async
    test('test orderStore', () async {
      // TODO
    });

  });
}

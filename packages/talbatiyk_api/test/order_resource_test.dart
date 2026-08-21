import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';

// tests for OrderResource
void main() {
  final instance = OrderResourceBuilder();
  // TODO add properties to the builder and call build()

  group(OrderResource, () {
    // String id
    test('to test the property `id`', () async {
      // TODO
    });

    // String status
    test('to test the property `status`', () async {
      // TODO
    });

    // String notes
    test('to test the property `notes`', () async {
      // TODO
    });

    // OrderService يحمّل items قبل إنشاء الـ Resource، لذلك العناصر جزء إلزامي من Create Order response.
    // BuiltList<OrderItemResource> items
    test('to test the property `items`', () async {
      // TODO
    });

    // DateTime createdAt
    test('to test the property `createdAt`', () async {
      // TODO
    });

    // DateTime updatedAt
    test('to test the property `updatedAt`', () async {
      // TODO
    });

  });
}

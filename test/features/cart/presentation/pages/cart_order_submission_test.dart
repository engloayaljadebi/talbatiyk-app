import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/presentation/pages/cart_page.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  testWidgets('submits the cart and stores the created order', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(cartProvider).addProduct(
      const ProductEntity(
        id: 'product-1',
        name: 'شاحن سريع',
        price: 4500,
        imageUrl: '',
        category: 'شواحن',
        brand: 'Samsung',
        isAvailable: true,
      ),
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CartPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('إرسال الطلبية'));
    await tester.pumpAndSettle();

    expect(container.read(cartProvider).isEmpty, isTrue);
    expect(container.read(ordersProvider).state.orders, hasLength(1));
    expect(find.text('السلة فارغة'), findsOneWidget);
  });
}

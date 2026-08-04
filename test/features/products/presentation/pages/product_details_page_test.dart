import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_card.dart';

void main() {
  const product = ProductEntity(
    id: 'product-1',
    name: 'شاحن سريع',
    price: 4500,
    imageUrl: '',
    category: 'شواحن',
    brand: 'Samsung',
    isAvailable: true,
    description: 'شاحن سريع مع ضمان سنة',
    colors: ['أسود', 'أبيض'],
    rating: 4.8,
  );

  testWidgets('opens product details and adds the product to cart', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 190,
                height: 330,
                child: ProductCard(product: product),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('شاحن سريع'));
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل المنتج'), findsOneWidget);
    expect(find.text('متوفر'), findsOneWidget);

    await tester.tap(find.text('إضافة'));
    await tester.pump();

    expect(container.read(cartProvider).quantityOf(product.id), 1);
  });

  testWidgets('adds from the card without opening details', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 190,
                height: 330,
                child: ProductCard(product: product),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('إضافة'));
    await tester.pump();

    expect(container.read(cartProvider).quantityOf(product.id), 1);
    expect(find.text('تفاصيل المنتج'), findsNothing);
  });
}

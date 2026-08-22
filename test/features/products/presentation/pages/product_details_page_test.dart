import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/widgets/add_to_cart_button.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_card.dart';

void main() {
  const product = ProductEntity(
    id: 'product-1',
    supplierId: 'supplier-123',
    supplierName: 'مورد الاختبار',
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

  testWidgets(
    'opens product details with supplier identity and no cart action',
    (tester) async {
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

      // Product Discovery is responsible only for opening Product Details.
      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل المنتج'), findsOneWidget);
      expect(find.text(product.name), findsWidgets);
      expect(find.text('متوفر'), findsOneWidget);

      // Cart/Follow belongs to Gate 2.4 and must not be exposed
      // while Gate 2.2 is being closed.
      expect(find.byType(AddToCartButton), findsNothing);

      // Supplier identity is below the initially visible viewport.
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -500));
      await tester.pumpAndSettle();

      // Gate 2.2 requires Product Details to expose the original
      // supplier identity using data already loaded by Discovery.
      expect(find.text('مورد الاختبار'), findsOneWidget);
      expect(find.text('supplier-123'), findsOneWidget);
      expect(find.text('product-1'), findsOneWidget);

      // Existing product details must remain available.
      expect(find.text(product.description), findsOneWidget);
      expect(find.text('أسود'), findsOneWidget);
      expect(find.text('أبيض'), findsOneWidget);
    },
  );

  testWidgets('product discovery card does not expose add-to-cart', (
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

    // Add-to-Cart must not be exposed directly from general Discovery.
    expect(find.byType(AddToCartButton), findsNothing);

    // الضغط على البطاقة يبقى مسؤولًا عن فتح Product Details.
    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل المنتج'), findsOneWidget);
    expect(find.text(product.name), findsWidgets);

    // Product Details also stays read-only until Gate 2.4.
    expect(find.byType(AddToCartButton), findsNothing);
  });
}

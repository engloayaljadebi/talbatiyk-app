import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/pages/product_details_page.dart';

void main() {
  testWidgets('matching managed Business exposes Product management', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [cartProvider.overrideWith((ref) => CartController())],
    );

    addTearDown(container.dispose);

    const product = ProductEntity(
      id: 'managed-1',
      supplierId: 'business-1',
      supplierName: 'Managed Supplier',
      name: 'Managed Product',
      price: 100,
      imageUrl: '',
      category: 'Tests',
      brand: 'Talbatiyk',
      isAvailable: true,
      serverVersion: 3,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: ProductDetailsPage(
            product: product,
            managedBusinessId: 'business-1',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('إدارة المنتج'), findsOneWidget);
  });

  testWidgets('public Product details do not expose supplier management', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [cartProvider.overrideWith((ref) => CartController())],
    );

    addTearDown(container.dispose);

    const product = ProductEntity(
      id: 'public-1',
      supplierId: 'business-1',
      supplierName: 'Managed Supplier',
      name: 'Public Product',
      price: 100,
      imageUrl: '',
      category: 'Tests',
      brand: 'Talbatiyk',
      isAvailable: true,
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductDetailsPage(product: product)),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byTooltip('إدارة المنتج'), findsNothing);
  });
}

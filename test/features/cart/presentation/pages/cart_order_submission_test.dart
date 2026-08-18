import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/cart/presentation/pages/cart_page.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  testWidgets('submits the cart and stores the created order', (
    WidgetTester tester,
  ) async {
    final AppDatabase database = AppDatabase.forTesting(
      NativeDatabase.memory(),
    );

    final ProviderContainer container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(database)],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    container
        .read(cartProvider)
        .addProduct(
          const ProductEntity(
            id: 'product-1',
            name: 'شاحن سريع',
            price: 4500,
            imageUrl: '',
            category: 'شواحن',
            brand: 'Samsung',
            isAvailable: true,
            supplierId: 'supplier-1',
            supplierName: 'مؤسسة الأمل',
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CartPage()),
      ),
    );

    await tester.pump();

    expect(find.text('إرسال الطلبية'), findsOneWidget);

    await tester.tap(find.text('إرسال الطلبية'));

    await tester.pump();

    for (int i = 0; i < 100; i++) {
      final ordersState = container.read(ordersProvider).state;

      if (!ordersState.isSubmitting) {
        break;
      }

      await tester.pump(const Duration(milliseconds: 50));
    }

    final ordersState = container.read(ordersProvider).state;

    expect(
      ordersState.isSubmitting,
      isFalse,
      reason: 'عملية إنشاء الطلب لم تنته',
    );

    expect(ordersState.errorMessage, isNull, reason: ordersState.errorMessage);

    expect(ordersState.orders, hasLength(1));

    final createdOrder = ordersState.orders.single;

    expect(createdOrder.items, hasLength(1));

    expect(createdOrder.items.single.productId, 'product-1');

    expect(createdOrder.items.single.supplierId, 'supplier-1');

    expect(createdOrder.items.single.supplierName, 'مؤسسة الأمل');

    expect(container.read(cartProvider).isEmpty, isTrue);

    await tester.pump();

    expect(find.text('السلة فارغة'), findsOneWidget);
  });
}

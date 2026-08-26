import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/cart/presentation/pages/cart_page.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

const ProductEntity _supplierAProduct = ProductEntity(
  id: 'product-a',
  name: 'شاحن سريع',
  price: 4500,
  imageUrl: '',
  category: 'شواحن',
  brand: 'Samsung',
  isAvailable: true,
  supplierId: 'supplier-a',
  supplierName: 'مؤسسة الأمل',
);

const ProductEntity _supplierBProduct = ProductEntity(
  id: 'product-b',
  name: 'سماعة لاسلكية',
  price: 7000,
  imageUrl: '',
  category: 'سماعات',
  brand: 'Sony',
  isAvailable: true,
  supplierId: 'supplier-b',
  supplierName: 'شركة النور',
);

void main() {
  testWidgets('submits a single-supplier cart and persists the order', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    final remoteDataSource = _FakeOrdersRemoteDataSource();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        ordersRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    // Arrange
    final cart = container.read(cartProvider);

    cart.addProduct(_supplierAProduct);

    expect(cart.isNotEmpty, isTrue);
    expect(cart.quantityOf(_supplierAProduct.id), 1);

    await _pumpCartPage(tester, container);

    expect(find.text(_supplierAProduct.name), findsOneWidget);

    // CartPage itself must not own the application-level
    // bottom navigation bar.
    //
    // MainPage is responsible for the global navigation surface.
    final cartScaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);

    expect(cartScaffold.bottomNavigationBar, isNull);

    // Verify the submit button BEFORE submitting.
    //
    // After a successful single-supplier submission,
    // the cart becomes empty and the button should disappear.
    final submitButton = find.widgetWithText(FilledButton, 'إرسال الطلبية');

    expect(submitButton, findsOneWidget);

    _expectWidgetInsideViewport(tester, submitButton);

    // Act
    await tester.tap(submitButton);
    await tester.pump();

    await _waitForSubmission(tester, container);

    // Assert orders state.
    final ordersState = container.read(ordersProvider).state;

    expect(ordersState.errorMessage, isNull, reason: ordersState.errorMessage);

    expect(ordersState.orders, hasLength(1));

    expect(ordersState.orders.single.items, hasLength(1));

    expect(
      ordersState.orders.single.items.single.productId,
      _supplierAProduct.id,
    );

    expect(
      ordersState.orders.single.items.single.supplierId,
      _supplierAProduct.supplierId,
    );

    // Assert remote request.
    expect(remoteDataSource.requests, hasLength(1));

    final request = remoteDataSource.requests.single;

    expect(request.items, hasLength(1));

    expect(request.items.single.productId, _supplierAProduct.id);

    expect(request.items.single.supplierId, _supplierAProduct.supplierId);

    // Assert local persistence.
    final persistedOrders = await container
        .read(ordersLocalDataSourceProvider)
        .getOrders();

    expect(persistedOrders, hasLength(1));

    expect(persistedOrders.single.items, hasLength(1));

    expect(persistedOrders.single.items.single.productId, _supplierAProduct.id);

    expect(
      persistedOrders.single.items.single.supplierId,
      _supplierAProduct.supplierId,
    );

    // The successfully submitted product must leave the cart.
    expect(cart.isEmpty, isTrue);

    expect(cart.quantityOf(_supplierAProduct.id), 0);

    await _expectEmptyCartUi(tester);

    // The checkout action must disappear when the cart is empty.
    expect(find.widgetWithText(FilledButton, 'إرسال الطلبية'), findsNothing);

    expect(find.text(_supplierAProduct.name), findsNothing);
  });

  testWidgets(
    'submits only selected supplier and keeps unselected supplier in cart',
    (WidgetTester tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      final remoteDataSource = _FakeOrdersRemoteDataSource();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ordersRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
        ],
      );

      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      // Arrange
      final cart = container.read(cartProvider);

      cart.addProduct(_supplierAProduct);
      cart.addProduct(_supplierBProduct);

      expect(cart.items, hasLength(2));

      await _pumpCartPage(tester, container);
      // Checkout يبقى جزءًا من CartPage نفسها عندما تحتوي السلة عناصر.
      expect(find.byKey(const ValueKey('checkout-bar')), findsOneWidget);

      expect(find.text(_supplierAProduct.name), findsOneWidget);

      expect(find.text(_supplierBProduct.name), findsOneWidget);

      final submitButton = find.widgetWithText(FilledButton, 'إرسال الطلبية');

      expect(submitButton, findsOneWidget);

      _expectWidgetInsideViewport(tester, submitButton);

      // Open supplier selection.
      await tester.tap(submitButton);
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      final supplierACheckbox = find.widgetWithText(
        CheckboxListTile,
        _supplierAProduct.supplierName,
      );

      final supplierBCheckbox = find.widgetWithText(
        CheckboxListTile,
        _supplierBProduct.supplierName,
      );

      expect(supplierACheckbox, findsOneWidget);

      expect(supplierBCheckbox, findsOneWidget);

      // All suppliers are selected by default.
      expect(tester.widget<CheckboxListTile>(supplierACheckbox).value, isTrue);

      expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isTrue);

      // Unselect Supplier B.
      await tester.tap(supplierBCheckbox);
      await tester.pump();

      expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isFalse);

      // Supplier A stays selected.
      expect(tester.widget<CheckboxListTile>(supplierACheckbox).value, isTrue);

      // Confirm Supplier A only.
      await _confirmSupplierSelection(tester);

      await _waitForSubmission(tester, container);

      // Assert remote request.
      expect(remoteDataSource.requests, hasLength(1));

      final request = remoteDataSource.requests.single;

      expect(request.items, hasLength(1));

      expect(request.items.single.productId, _supplierAProduct.id);

      expect(request.items.single.supplierId, _supplierAProduct.supplierId);

      // Assert in-memory orders state.
      final ordersState = container.read(ordersProvider).state;

      expect(
        ordersState.errorMessage,
        isNull,
        reason: ordersState.errorMessage,
      );

      expect(ordersState.orders, hasLength(1));

      expect(ordersState.orders.single.items, hasLength(1));

      expect(
        ordersState.orders.single.items.single.supplierId,
        _supplierAProduct.supplierId,
      );

      // Supplier A was submitted and removed.
      expect(cart.quantityOf(_supplierAProduct.id), 0);

      // Supplier B was not submitted and must remain.
      expect(cart.quantityOf(_supplierBProduct.id), 1);
      // عند إفراغ السلة بعد نجاح الطلب يجب إزالة Checkout bar.
      // Supplier B لم يُرسل وما زال موجودًا، لذلك يجب أن تبقى Checkout bar.
      expect(find.byKey(const ValueKey('checkout-bar')), findsOneWidget);
      expect(cart.items, hasLength(1));

      expect(cart.isEmpty, isFalse);

      // Assert local persistence.
      final persistedOrders = await container
          .read(ordersLocalDataSourceProvider)
          .getOrders();

      expect(persistedOrders, hasLength(1));

      expect(persistedOrders.single.items, hasLength(1));

      expect(
        persistedOrders.single.items.single.productId,
        _supplierAProduct.id,
      );

      expect(
        persistedOrders.single.items.single.supplierId,
        _supplierAProduct.supplierId,
      );

      // Rebuild UI after cart mutation.
      await tester.pump();

      expect(find.text(_supplierAProduct.name), findsNothing);

      expect(find.text(_supplierBProduct.name), findsOneWidget);

      expect(
        find.byKey(const ValueKey('cart-content')),
        findsOneWidget,
      ); // بقاء Supplier B يعني أن Checkout يجب أن يبقى متاحًا.
      expect(find.byKey(const ValueKey('checkout-bar')), findsOneWidget);

      // Because Supplier B remains in the cart,
      // the checkout action must remain available.
      final remainingSubmitButton = find.widgetWithText(
        FilledButton,
        'إرسال الطلبية',
      );

      expect(remainingSubmitButton, findsOneWidget);

      _expectWidgetInsideViewport(tester, remainingSubmitButton);
    },
  );

  testWidgets('submits products from all selected suppliers in one order', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    final remoteDataSource = _FakeOrdersRemoteDataSource();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        ordersRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    // Arrange
    final cart = container.read(cartProvider);

    cart.addProduct(_supplierAProduct);
    cart.addProduct(_supplierBProduct);

    expect(cart.items, hasLength(2));

    await _pumpCartPage(tester, container);
    // Supplier B ما زال موجودًا في السلة، لذلك يجب أن تبقى Checkout bar.
    expect(find.byKey(const ValueKey('checkout-bar')), findsOneWidget);
    final submitButton = find.widgetWithText(FilledButton, 'إرسال الطلبية');

    expect(submitButton, findsOneWidget);

    _expectWidgetInsideViewport(tester, submitButton);

    // Open supplier selection.
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);

    expect(find.byType(CheckboxListTile), findsNWidgets(2));

    final supplierACheckbox = find.widgetWithText(
      CheckboxListTile,
      _supplierAProduct.supplierName,
    );

    final supplierBCheckbox = find.widgetWithText(
      CheckboxListTile,
      _supplierBProduct.supplierName,
    );

    expect(tester.widget<CheckboxListTile>(supplierACheckbox).value, isTrue);

    expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isTrue);

    // Both suppliers are selected by default.
    await _confirmSupplierSelection(tester);

    await _waitForSubmission(tester, container);

    // Assert remote request.
    expect(remoteDataSource.requests, hasLength(1));

    final request = remoteDataSource.requests.single;

    expect(request.items, hasLength(2));

    expect(request.items.map((item) => item.supplierId).toSet(), <String>{
      _supplierAProduct.supplierId,
      _supplierBProduct.supplierId,
    });

    expect(request.items.map((item) => item.productId).toSet(), <String>{
      _supplierAProduct.id,
      _supplierBProduct.id,
    });

    // Assert state.
    final ordersState = container.read(ordersProvider).state;

    expect(ordersState.errorMessage, isNull, reason: ordersState.errorMessage);

    expect(ordersState.orders, hasLength(1));

    expect(ordersState.orders.single.items, hasLength(2));

    expect(
      ordersState.orders.single.items.map((item) => item.supplierId).toSet(),
      <String>{_supplierAProduct.supplierId, _supplierBProduct.supplierId},
    );

    // Assert local persistence.
    final persistedOrders = await container
        .read(ordersLocalDataSourceProvider)
        .getOrders();

    expect(persistedOrders, hasLength(1));

    expect(persistedOrders.single.items, hasLength(2));

    expect(
      persistedOrders.single.items.map((item) => item.supplierId).toSet(),
      <String>{_supplierAProduct.supplierId, _supplierBProduct.supplierId},
    );

    expect(
      persistedOrders.single.items.map((item) => item.productId).toSet(),
      <String>{_supplierAProduct.id, _supplierBProduct.id},
    );

    // Every supplier was successfully submitted.
    expect(cart.isEmpty, isTrue);

    await _expectEmptyCartUi(tester);

    expect(find.text(_supplierAProduct.name), findsNothing);

    expect(find.text(_supplierBProduct.name), findsNothing);

    expect(find.widgetWithText(FilledButton, 'إرسال الطلبية'), findsNothing);
  });
}

/// Builds CartPage using the exact ProviderContainer created by the test.
///
/// This keeps the test hermetic while allowing Cart, Orders and Drift
/// to share the same controlled test dependencies.
Future<void> _pumpCartPage(
  WidgetTester tester,
  ProviderContainer container,
) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(home: CartPage()),
    ),
  );

  await tester.pump();
}

/// Confirms the currently displayed supplier-selection dialog.
Future<void> _confirmSupplierSelection(WidgetTester tester) async {
  final dialog = find.byType(AlertDialog);

  expect(dialog, findsOneWidget);

  final submitButton = find.descendant(
    of: dialog,
    matching: find.byType(FilledButton),
  );

  expect(submitButton, findsOneWidget);

  await tester.tap(submitButton);
  await tester.pump();
}

/// Waits for OrdersController to finish submission without using
/// pumpAndSettle.
///
/// This is intentional: animated progress indicators may keep scheduling
/// frames and make pumpAndSettle unsuitable for asynchronous submit flows.
Future<void> _waitForSubmission(
  WidgetTester tester,
  ProviderContainer container,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    final state = container.read(ordersProvider).state;

    if (!state.isSubmitting) {
      // Give Riverpod/Flutter one frame to reflect the final state in the UI.
      await tester.pump();
      return;
    }

    await tester.pump(const Duration(milliseconds: 50));
  }

  fail('Order submission did not complete before timeout.');
}

/// Verifies the transition from cart-content to empty-cart.
Future<void> _expectEmptyCartUi(WidgetTester tester) async {
  // Start AnimatedSwitcher transition.
  await tester.pump();

  expect(find.byKey(const ValueKey('empty-cart')), findsOneWidget);

  // CartPage currently uses a 320ms AnimatedSwitcher.
  await tester.pump(const Duration(milliseconds: 400));

  expect(find.byKey(const ValueKey('cart-content')), findsNothing);
}

/// Confirms that an important action is visually inside the logical
/// Flutter viewport.
///
/// tester.view.physicalSize is expressed in physical pixels, while widget
/// coordinates are logical pixels, therefore devicePixelRatio must be used.
void _expectWidgetInsideViewport(WidgetTester tester, Finder finder) {
  expect(finder, findsOneWidget);

  final rect = tester.getRect(finder);

  final logicalWidth =
      tester.view.physicalSize.width / tester.view.devicePixelRatio;

  final logicalHeight =
      tester.view.physicalSize.height / tester.view.devicePixelRatio;

  expect(rect.left, greaterThanOrEqualTo(0));

  expect(rect.top, greaterThanOrEqualTo(0));

  expect(rect.right, lessThanOrEqualTo(logicalWidth));

  expect(rect.bottom, lessThanOrEqualTo(logicalHeight));
}

/// Fake remote Orders datasource.
///
/// The purpose of this fake is to verify the exact request that would be
/// sent to the backend while keeping the widget tests fully deterministic.
class _FakeOrdersRemoteDataSource implements OrdersDataSource {
  final List<CreateOrderModel> requests = <CreateOrderModel>[];

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    requests.add(request);

    return OrderModel(
      id: 'server-order-${requests.length}',
      status: 'pending',
      items: request.items,
      createdAt: DateTime.utc(2026, 8, 24, 12),
      notes: request.notes,
    );
  }

  @override
  Future<List<OrderModel>> getOrders() {
    throw UnsupportedError('GET orders is not used by this test.');
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    throw UnsupportedError('Order status updates are not used by this test.');
  }
}

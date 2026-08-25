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

    container.read(cartProvider).addProduct(_supplierAProduct);

    await _pumpCartPage(tester, container);

    await tester.tap(find.text('إرسال الطلبية'));
    await tester.pump();

    await _waitForSubmission(tester, container);

    final ordersState = container.read(ordersProvider).state;

    expect(ordersState.errorMessage, isNull, reason: ordersState.errorMessage);
    expect(ordersState.orders, hasLength(1));

    expect(remoteDataSource.requests, hasLength(1));

    final request = remoteDataSource.requests.single;

    expect(request.items, hasLength(1));
    expect(request.items.single.productId, _supplierAProduct.id);
    expect(request.items.single.supplierId, _supplierAProduct.supplierId);

    final persistedOrders = await container
        .read(ordersLocalDataSourceProvider)
        .getOrders();

    expect(persistedOrders, hasLength(1));
    expect(persistedOrders.single.items, hasLength(1));
    expect(
      persistedOrders.single.items.single.supplierId,
      _supplierAProduct.supplierId,
    );

    expect(container.read(cartProvider).isEmpty, isTrue);

    await _expectEmptyCartUi(tester);

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

      final cart = container.read(cartProvider);

      cart.addProduct(_supplierAProduct);
      cart.addProduct(_supplierBProduct);

      await _pumpCartPage(tester, container);

      expect(cart.items, hasLength(2));
      expect(find.text(_supplierAProduct.name), findsOneWidget);
      expect(find.text(_supplierBProduct.name), findsOneWidget);

      await tester.tap(find.text('إرسال الطلبية'));
      await tester.pump();

      expect(find.byType(AlertDialog), findsOneWidget);

      final supplierBCheckbox = find.widgetWithText(
        CheckboxListTile,
        _supplierBProduct.supplierName,
      );

      expect(supplierBCheckbox, findsOneWidget);

      // الموردون محددون افتراضيًا جميعًا.
      expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isTrue);

      // نلغي Supplier B ونرسل Supplier A فقط.
      await tester.tap(supplierBCheckbox);
      await tester.pump();

      expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isFalse);

      await _confirmSupplierSelection(tester);

      await _waitForSubmission(tester, container);

      expect(remoteDataSource.requests, hasLength(1));

      final request = remoteDataSource.requests.single;

      expect(request.items, hasLength(1));
      expect(request.items.single.productId, _supplierAProduct.id);
      expect(request.items.single.supplierId, _supplierAProduct.supplierId);

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

      // Supplier A أُرسل وحُذف فقط.
      // Supplier B لم يدخل الطلب ويجب أن يبقى في Cart.
      expect(cart.quantityOf(_supplierAProduct.id), 0);
      expect(cart.quantityOf(_supplierBProduct.id), 1);
      expect(cart.items, hasLength(1));
      expect(cart.isEmpty, isFalse);

      final persistedOrders = await container
          .read(ordersLocalDataSourceProvider)
          .getOrders();

      expect(persistedOrders, hasLength(1));
      expect(persistedOrders.single.items, hasLength(1));
      expect(
        persistedOrders.single.items.single.supplierId,
        _supplierAProduct.supplierId,
      );

      await tester.pump();

      expect(find.text(_supplierAProduct.name), findsNothing);
      expect(find.text(_supplierBProduct.name), findsOneWidget);
      expect(find.byKey(const ValueKey('cart-content')), findsOneWidget);
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

    final cart = container.read(cartProvider);

    cart.addProduct(_supplierAProduct);
    cart.addProduct(_supplierBProduct);

    await _pumpCartPage(tester, container);

    await tester.tap(find.text('إرسال الطلبية'));
    await tester.pump();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.byType(CheckboxListTile), findsNWidgets(2));

    // الافتراضي هو تحديد جميع الموردين؛ نؤكد الاختيار كما هو.
    await _confirmSupplierSelection(tester);

    await _waitForSubmission(tester, container);

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

    final ordersState = container.read(ordersProvider).state;

    expect(ordersState.errorMessage, isNull, reason: ordersState.errorMessage);
    expect(ordersState.orders, hasLength(1));
    expect(ordersState.orders.single.items, hasLength(2));

    expect(
      ordersState.orders.single.items.map((item) => item.supplierId).toSet(),
      <String>{_supplierAProduct.supplierId, _supplierBProduct.supplierId},
    );

    final persistedOrders = await container
        .read(ordersLocalDataSourceProvider)
        .getOrders();

    expect(persistedOrders, hasLength(1));
    expect(persistedOrders.single.items, hasLength(2));

    expect(
      persistedOrders.single.items.map((item) => item.supplierId).toSet(),
      <String>{_supplierAProduct.supplierId, _supplierBProduct.supplierId},
    );

    // كل الموردين دخلوا الطلب الناجح.
    expect(cart.isEmpty, isTrue);

    await _expectEmptyCartUi(tester);

    expect(find.text(_supplierAProduct.name), findsNothing);
    expect(find.text(_supplierBProduct.name), findsNothing);
  });
}

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

Future<void> _waitForSubmission(
  WidgetTester tester,
  ProviderContainer container,
) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    final state = container.read(ordersProvider).state;

    if (!state.isSubmitting) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 50));
  }

  fail('Order submission did not complete before timeout.');
}

Future<void> _expectEmptyCartUi(WidgetTester tester) async {
  // يبدأ AnimatedSwitcher الانتقال من cart-content إلى empty-cart.
  await tester.pump();

  expect(find.byKey(const ValueKey('empty-cart')), findsOneWidget);

  // مدة AnimatedSwitcher الحالية 320ms.
  await tester.pump(const Duration(milliseconds: 400));

  expect(find.byKey(const ValueKey('cart-content')), findsNothing);
}

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

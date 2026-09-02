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
import 'package:talbatiyk/features/supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/repositories/supplier_discovery_repository.dart';
import 'package:talbatiyk/features/supplier_discovery/presentation/providers/supplier_discovery_provider.dart';

const ProductEntity _supplierAProduct = ProductEntity(
  id: 'product-a',
  name: 'Product A',
  price: 4500,
  imageUrl: '',
  category: 'Category A',
  brand: 'Brand A',
  isAvailable: true,
  supplierId: 'supplier-a',
  supplierName: 'Source Supplier A',
);

const ProductEntity _supplierBProduct = ProductEntity(
  id: 'product-b',
  name: 'Product B',
  price: 7000,
  imageUrl: '',
  category: 'Category B',
  brand: 'Brand B',
  isAvailable: true,
  supplierId: 'supplier-b',
  supplierName: 'Source Supplier B',
);

const SupplierCandidateEntity _supplierA = SupplierCandidateEntity(
  id: 'supplier-a',
  name: 'Supplier A',
);

const SupplierCandidateEntity _supplierB = SupplierCandidateEntity(
  id: 'supplier-b',
  name: 'Supplier B',
);

void main() {
  testWidgets(
    'requires explicit supplier selection even when one candidate exists',
    (WidgetTester tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final remoteDataSource = _FakeOrdersRemoteDataSource();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ordersRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
          supplierDiscoveryRepositoryProvider.overrideWithValue(
            const _FakeSupplierDiscoveryRepository(<SupplierCandidateEntity>[
              _supplierA,
            ]),
          ),
        ],
      );

      addTearDown(() async {
        container.dispose();
        await database.close();
      });

      final cart = container.read(cartProvider);

      cart.addProduct(_supplierAProduct);

      await _pumpCartPage(tester, container);

      final checkoutButton = find.widgetWithText(FilledButton, 'إرسال الطلبية');

      expect(checkoutButton, findsOneWidget);

      await tester.tap(checkoutButton);
      await _waitForSupplierDialog(tester);

      final supplierCheckbox = find.widgetWithText(
        CheckboxListTile,
        _supplierA.name,
      );

      expect(supplierCheckbox, findsOneWidget);

      // Explicit selection: even the only candidate starts unselected.
      expect(tester.widget<CheckboxListTile>(supplierCheckbox).value, isFalse);

      await tester.tap(supplierCheckbox);
      await tester.pump();

      expect(tester.widget<CheckboxListTile>(supplierCheckbox).value, isTrue);

      await _confirmSupplierSelection(tester);

      await _waitForSubmission(tester, container, remoteDataSource);

      expect(remoteDataSource.requests, hasLength(1));

      final request = remoteDataSource.requests.single;

      expect(request.supplierIds, <String>['supplier-a']);
      expect(request.items, hasLength(1));
      expect(request.items.single.productId, _supplierAProduct.id);
      expect(request.items.single.supplierId, 'supplier-a');

      final persistedOrders = await container
          .read(ordersLocalDataSourceProvider)
          .getOrders();

      expect(persistedOrders, hasLength(1));
      expect(persistedOrders.single.items, hasLength(1));

      expect(cart.isEmpty, isTrue);

      await _expectEmptyCartUi(tester);
    },
  );

  testWidgets('selected recipient receives the entire cross-source basket', (
    WidgetTester tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    final remoteDataSource = _FakeOrdersRemoteDataSource();

    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        ordersRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
        supplierDiscoveryRepositoryProvider.overrideWithValue(
          const _FakeSupplierDiscoveryRepository(<SupplierCandidateEntity>[
            _supplierA,
            _supplierB,
          ]),
        ),
      ],
    );

    addTearDown(() async {
      container.dispose();
      await database.close();
    });

    final cart = container.read(cartProvider);

    cart.addProduct(_supplierAProduct);
    cart.addProduct(_supplierBProduct);

    expect(cart.items, hasLength(2));

    await _pumpCartPage(tester, container);

    final checkoutButton = find.widgetWithText(FilledButton, 'إرسال الطلبية');

    expect(checkoutButton, findsOneWidget);

    await tester.tap(checkoutButton);
    await _waitForSupplierDialog(tester);

    final supplierACheckbox = find.widgetWithText(
      CheckboxListTile,
      _supplierA.name,
    );

    final supplierBCheckbox = find.widgetWithText(
      CheckboxListTile,
      _supplierB.name,
    );

    expect(supplierACheckbox, findsOneWidget);
    expect(supplierBCheckbox, findsOneWidget);

    // Recipient selection is explicit, not inferred from product sources.
    expect(tester.widget<CheckboxListTile>(supplierACheckbox).value, isFalse);
    expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isFalse);

    // Select only Supplier A as the RFQ recipient.
    await tester.tap(supplierACheckbox);
    await tester.pump();

    await _confirmSupplierSelection(tester);

    await _waitForSubmission(tester, container, remoteDataSource);

    expect(remoteDataSource.requests, hasLength(1));

    final request = remoteDataSource.requests.single;

    // Routing authority: only Supplier A is a recipient.
    expect(request.supplierIds, <String>['supplier-a']);

    // Basket authority: both products are submitted unchanged.
    expect(request.items, hasLength(2));

    expect(request.items.map((item) => item.productId).toSet(), <String>{
      'product-a',
      'product-b',
    });

    // Product supplier remains catalog/source provenance.
    expect(request.items.map((item) => item.supplierId).toSet(), <String>{
      'supplier-a',
      'supplier-b',
    });

    final ordersState = container.read(ordersProvider).state;

    expect(ordersState.errorMessage, isNull, reason: ordersState.errorMessage);

    expect(ordersState.orders, hasLength(1));
    expect(ordersState.orders.single.items, hasLength(2));

    final persistedOrders = await container
        .read(ordersLocalDataSourceProvider)
        .getOrders();

    expect(persistedOrders, hasLength(1));
    expect(persistedOrders.single.items, hasLength(2));

    expect(
      persistedOrders.single.items.map((item) => item.productId).toSet(),
      <String>{'product-a', 'product-b'},
    );

    // The whole basket entered the RFQ, therefore the whole cart is cleared.
    expect(cart.isEmpty, isTrue);
    expect(cart.quantityOf(_supplierAProduct.id), 0);
    expect(cart.quantityOf(_supplierBProduct.id), 0);

    await _expectEmptyCartUi(tester);

    expect(find.byKey(const ValueKey('checkout-bar')), findsNothing);
  });

  testWidgets(
    'multiple selected recipients receive the same entire basket request',
    (WidgetTester tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      final remoteDataSource = _FakeOrdersRemoteDataSource();

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          ordersRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
          supplierDiscoveryRepositoryProvider.overrideWithValue(
            const _FakeSupplierDiscoveryRepository(<SupplierCandidateEntity>[
              _supplierA,
              _supplierB,
            ]),
          ),
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

      final checkoutButton = find.widgetWithText(FilledButton, 'إرسال الطلبية');

      await tester.tap(checkoutButton);
      await _waitForSupplierDialog(tester);

      final supplierACheckbox = find.widgetWithText(
        CheckboxListTile,
        _supplierA.name,
      );

      final supplierBCheckbox = find.widgetWithText(
        CheckboxListTile,
        _supplierB.name,
      );

      await tester.tap(supplierACheckbox);
      await tester.pump();

      await tester.tap(supplierBCheckbox);
      await tester.pump();

      expect(tester.widget<CheckboxListTile>(supplierACheckbox).value, isTrue);
      expect(tester.widget<CheckboxListTile>(supplierBCheckbox).value, isTrue);

      await _confirmSupplierSelection(tester);

      await _waitForSubmission(tester, container, remoteDataSource);

      expect(remoteDataSource.requests, hasLength(1));

      final request = remoteDataSource.requests.single;

      expect(request.supplierIds, <String>['supplier-a', 'supplier-b']);

      expect(request.items, hasLength(2));

      expect(request.items.map((item) => item.productId).toSet(), <String>{
        'product-a',
        'product-b',
      });

      expect(request.items.map((item) => item.supplierId).toSet(), <String>{
        'supplier-a',
        'supplier-b',
      });

      final persistedOrders = await container
          .read(ordersLocalDataSourceProvider)
          .getOrders();

      expect(persistedOrders, hasLength(1));
      expect(persistedOrders.single.items, hasLength(2));

      expect(cart.isEmpty, isTrue);

      await _expectEmptyCartUi(tester);
    },
  );
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

Future<void> _waitForSupplierDialog(WidgetTester tester) async {
  for (var attempt = 0; attempt < 100; attempt++) {
    if (find.byType(AlertDialog).evaluate().isNotEmpty) {
      return;
    }

    await tester.pump(const Duration(milliseconds: 20));
  }

  fail('Supplier selection dialog did not appear before timeout.');
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
  _FakeOrdersRemoteDataSource remoteDataSource,
) async {
  var requestStarted = false;

  for (var attempt = 0; attempt < 100; attempt++) {
    if (remoteDataSource.requests.isNotEmpty) {
      requestStarted = true;
    }

    final state = container.read(ordersProvider).state;

    if (requestStarted && !state.isSubmitting) {
      await tester.pump();
      return;
    }

    await tester.pump(const Duration(milliseconds: 50));
  }

  fail('Order submission did not complete before timeout.');
}

Future<void> _expectEmptyCartUi(WidgetTester tester) async {
  await tester.pump();

  expect(find.byKey(const ValueKey('empty-cart')), findsOneWidget);

  await tester.pump(const Duration(milliseconds: 400));

  expect(find.byKey(const ValueKey('cart-content')), findsNothing);
}

final class _FakeSupplierDiscoveryRepository
    implements SupplierDiscoveryRepository {
  const _FakeSupplierDiscoveryRepository(this.suppliers);

  final List<SupplierCandidateEntity> suppliers;

  @override
  Future<List<SupplierCandidateEntity>> getSuppliers() async {
    return suppliers;
  }
}

final class _FakeOrdersRemoteDataSource implements OrdersDataSource {
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
}

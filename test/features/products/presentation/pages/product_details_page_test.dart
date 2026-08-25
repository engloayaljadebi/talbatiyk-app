import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/pages/product_details_page.dart';
import 'package:talbatiyk/features/products/presentation/widgets/add_to_cart_button.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_card.dart';
import 'package:talbatiyk/features/supplier_follow/domain/repositories/supplier_follow_repository.dart';
import 'package:talbatiyk/features/supplier_follow/presentation/providers/supplier_follow_provider.dart';

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
    'opens product details with supplier identity, follow, and no cart action',
    (tester) async {
      final repository = _FakeSupplierFollowRepository();
      final container = _createContainer(repository);
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

      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل المنتج'), findsOneWidget);
      expect(find.text(product.name), findsWidgets);
      expect(find.text('متوفر'), findsOneWidget);

      // Add-to-Cart remains closed until Gate 2.4.
      expect(find.byType(AddToCartButton), findsNothing);

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('مورد الاختبار'), findsOneWidget);
      expect(find.text('supplier-123'), findsOneWidget);
      expect(find.text('product-1'), findsOneWidget);

      // Follow is now part of Gate 2.3.
      expect(find.text('متابعة المورد'), findsWidgets);

      expect(find.text(product.description), findsOneWidget);
      expect(find.text('أسود'), findsOneWidget);
      expect(find.text('أبيض'), findsOneWidget);
    },
  );

  testWidgets(
    'confirms follow before adding product from an unfollowed supplier',
    (tester) async {
      final repository = _FakeSupplierFollowRepository(
        isFollowingResult: false,
      );
      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ProductDetailsPage(product: product)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(AddToCartButton),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AddToCartButton));
      await tester.pumpAndSettle();

      expect(find.text('متابعة المورد وإضافة المنتج'), findsOneWidget);
      expect(container.read(cartProvider).quantityOf(product.id), 0);
      expect(repository.followCalls, 0);

      await tester.tap(find.widgetWithText(FilledButton, 'متابعة وإضافة'));
      await tester.pumpAndSettle();

      expect(repository.followCalls, 1);
      expect(container.read(cartProvider).quantityOf(product.id), 1);
    },
  );

  testWidgets('does not add product when required follow fails', (
    tester,
  ) async {
    final repository = _FakeSupplierFollowRepository(isFollowingResult: false)
      ..failNextFollow = true;

    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductDetailsPage(product: product)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(AddToCartButton),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AddToCartButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(FilledButton, 'متابعة وإضافة'));
    await tester.pumpAndSettle();

    expect(repository.followCalls, 1);
    expect(container.read(cartProvider).quantityOf(product.id), 0);
  });

  testWidgets('product discovery card exposes add-to-cart', (
    WidgetTester tester,
  ) async {
    final repository = _FakeSupplierFollowRepository();
    final container = _createContainer(repository);
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

    // Product Discovery تدعم الإضافة المباشرة دون فتح Details.
    expect(find.byType(AddToCartButton), findsOneWidget);
    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل المنتج'), findsOneWidget);
    expect(find.text(product.name), findsWidgets);

    // Product Details still has no cart action in Gate 2.3.
    expect(find.byType(AddToCartButton), findsNothing);
  });

  testWidgets('adds product directly when supplier is already followed', (
    tester,
  ) async {
    final repository = _FakeSupplierFollowRepository(isFollowingResult: true);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductDetailsPage(product: product)),
      ),
    );

    await tester.pumpAndSettle();

    expect(container.read(cartProvider).isEmpty, isTrue);

    await tester.scrollUntilVisible(
      find.byType(AddToCartButton),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final addToCartButton = find.byType(AddToCartButton);
    expect(addToCartButton, findsOneWidget);

    await tester.tap(addToCartButton);
    await tester.pumpAndSettle();

    final CartController cart = container.read(cartProvider);

    expect(cart.quantityOf(product.id), 1);
    expect(repository.followCalls, 0);
    expect(repository.unfollowCalls, 0);
  });

  testWidgets('follows supplier from product details', (tester) async {
    final repository = _FakeSupplierFollowRepository(isFollowingResult: false);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductDetailsPage(product: product)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    final followButton = find.widgetWithText(FilledButton, 'متابعة المورد');

    expect(followButton, findsOneWidget);

    await tester.tap(followButton);
    await tester.pumpAndSettle();

    expect(repository.followCalls, 1);
    expect(find.widgetWithText(FilledButton, 'تتم المتابعة'), findsOneWidget);

    expect(find.byType(AddToCartButton), findsOneWidget);
  });

  testWidgets('shows follow load error and retries', (tester) async {
    final repository = _FakeSupplierFollowRepository(failNextLoad: true);
    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductDetailsPage(product: product)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.text('تعذر تحميل حالة متابعة المورد.'), findsOneWidget);

    final retryButton = find.widgetWithText(TextButton, 'إعادة المحاولة');

    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pumpAndSettle();

    expect(repository.isFollowingCalls, 2);
    expect(find.widgetWithText(FilledButton, 'متابعة المورد'), findsOneWidget);
  });

  testWidgets(
    'prevents duplicate follow and cart insertion while add flow is running',
    (tester) async {
      final repository = _FakeSupplierFollowRepository(isFollowingResult: false)
        ..followCompleter = Completer<bool>();

      final container = _createContainer(repository);
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ProductDetailsPage(product: product)),
        ),
      );

      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byType(AddToCartButton),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byType(AddToCartButton));
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'متابعة وإضافة'));
      await tester.pump();

      expect(repository.followCalls, 1);
      expect(container.read(cartProvider).quantityOf(product.id), 0);

      await tester.tap(find.byType(AddToCartButton));
      await tester.pump();

      expect(repository.followCalls, 1);
      expect(container.read(cartProvider).quantityOf(product.id), 0);

      repository.followCompleter!.complete(true);
      await tester.pumpAndSettle();

      expect(repository.followCalls, 1);
      expect(container.read(cartProvider).quantityOf(product.id), 1);
    },
  );

  testWidgets('does not follow or add product when confirmation is cancelled', (
    tester,
  ) async {
    final repository = _FakeSupplierFollowRepository(isFollowingResult: false);

    final container = _createContainer(repository);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ProductDetailsPage(product: product)),
      ),
    );

    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.byType(AddToCartButton),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(AddToCartButton));
    await tester.pumpAndSettle();

    expect(find.text('متابعة المورد وإضافة المنتج'), findsOneWidget);

    await tester.tap(find.widgetWithText(TextButton, 'إلغاء'));
    await tester.pumpAndSettle();

    expect(repository.followCalls, 0);
    expect(repository.unfollowCalls, 0);
    expect(container.read(cartProvider).quantityOf(product.id), 0);
  });
}

ProviderContainer _createContainer(SupplierFollowRepository repository) {
  return ProviderContainer(
    overrides: [
      supplierFollowRepositoryProvider.overrideWithValue(repository),

      // Product Details tests must stay hermetic.
      // Do not allow cartProvider to create the real AppDatabase/Drift
      // persistence layer during widget tests.
      cartProvider.overrideWith((ref) => CartController()),
    ],
  );
}

final class _FakeSupplierFollowRepository implements SupplierFollowRepository {
  _FakeSupplierFollowRepository({
    this.isFollowingResult = false,
    this.failNextLoad = false,
  });

  bool isFollowingResult;
  bool failNextLoad;
  bool failNextFollow = false;
  Completer<bool>? followCompleter;

  int isFollowingCalls = 0;
  int followCalls = 0;
  int unfollowCalls = 0;

  @override
  Future<bool> isFollowing(String businessId) async {
    isFollowingCalls += 1;

    if (failNextLoad) {
      failNextLoad = false;
      throw StateError('follow status failed');
    }

    return isFollowingResult;
  }

  @override
  Future<bool> follow(String businessId) async {
    followCalls += 1;

    if (failNextFollow) {
      failNextFollow = false;
      throw StateError('follow failed');
    }

    final completer = followCompleter;

    if (completer != null) {
      final result = await completer.future;
      isFollowingResult = result;
      return result;
    }

    isFollowingResult = true;
    return true;
  }

  @override
  Future<bool> unfollow(String businessId) async {
    unfollowCalls += 1;
    isFollowingResult = false;
    return false;
  }
}

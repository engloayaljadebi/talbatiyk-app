import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('product discovery card does not expose add-to-cart', (
    tester,
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

    expect(find.byType(AddToCartButton), findsNothing);

    await tester.tap(find.byType(ProductCard));
    await tester.pumpAndSettle();

    expect(find.text('تفاصيل المنتج'), findsOneWidget);
    expect(find.text(product.name), findsWidgets);

    // Product Details still has no cart action in Gate 2.3.
    expect(find.byType(AddToCartButton), findsNothing);
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

    expect(find.byType(AddToCartButton), findsNothing);
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
}

ProviderContainer _createContainer(SupplierFollowRepository repository) {
  return ProviderContainer(
    overrides: [supplierFollowRepositoryProvider.overrideWithValue(repository)],
  );
}

final class _FakeSupplierFollowRepository implements SupplierFollowRepository {
  _FakeSupplierFollowRepository({
    this.isFollowingResult = false,
    this.failNextLoad = false,
  });

  bool isFollowingResult;
  bool failNextLoad;

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

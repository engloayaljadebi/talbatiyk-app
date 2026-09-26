import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/auth/domain/repositories/auth_repository.dart';
import 'package:talbatiyk/features/auth/domain/usecases/auth_usecase.dart';
import 'package:talbatiyk/features/auth/presentation/controllers/auth_controller.dart';
import 'package:talbatiyk/features/auth/presentation/providers/auth_providers.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/home/presentation/pages/home_page.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/data/repositories/products_repository_impl.dart';
import 'package:talbatiyk/features/products/domain/usecases/products_usecase.dart';
import 'package:talbatiyk/features/products/presentation/controllers/products_controller.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';

void main() {
  testWidgets(
    'Home shows real product categories and applies selected category',
    (tester) async {
      final productsRepository = ProductsRepositoryImpl(
        const _FakeProductsDataSource([
          ProductModel(
            id: 'product-1',
            name: 'شاحن سريع',
            price: 4500,
            imageUrl: '',
            category: 'شواحن',
            brand: 'Samsung',
            isAvailable: true,
          ),
          ProductModel(
            id: 'product-2',
            name: 'سماعة لاسلكية',
            price: 15000,
            imageUrl: '',
            category: 'سماعات',
            brand: 'Apple',
            isAvailable: true,
          ),
        ]),
      );

      final productsController = ProductsController(
        ProductsUseCase(productsRepository),
        autoLoad: false,
      );

      await productsController.loadProducts();

      final authController = AuthController(
        AuthUseCase(_UnusedAuthRepository()),
        autoRestore: false,
      );

      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWith((ref) => authController),
          cartProvider.overrideWith((ref) => CartController()),
          productDiscoveryProvider.overrideWith((ref) => productsController),
        ],
      );

      addTearDown(container.dispose);

      var productsOpened = false;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: HomePage(
              onViewProducts: () {
                productsOpened = true;
              },
              onOpenCart: () {},
              onOpenNotifications: () {},
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('الأقسام'), findsOneWidget);

      expect(
        find.byKey(const ValueKey<String>('home-category-شواحن')),
        findsOneWidget,
      );

      expect(
        find.byKey(const ValueKey<String>('home-category-سماعات')),
        findsOneWidget,
      );

      await tester.tap(
        find.byKey(const ValueKey<String>('home-category-شواحن')),
      );

      await tester.pump();

      expect(productsController.state.selectedCategory, 'شواحن');

      expect(productsController.state.search, isEmpty);

      expect(productsController.state.products, hasLength(1));

      expect(productsController.state.products.single.id, 'product-1');

      expect(productsOpened, isTrue);
    },
  );
}

final class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async => products;
}

final class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

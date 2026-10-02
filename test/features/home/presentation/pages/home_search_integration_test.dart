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
import 'package:talbatiyk/features/products/domain/repositories/products_repository.dart';
import 'package:talbatiyk/features/products/domain/usecases/products_usecase.dart';
import 'package:talbatiyk/features/products/presentation/controllers/products_controller.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';

void main() {
  testWidgets(
    'Home search updates real Product Discovery state then opens products',
    (tester) async {
      final authController = AuthController(
        AuthUseCase(_UnusedAuthRepository()),
        autoRestore: false,
      );

      final productsController = ProductsController(
        ProductsUseCase(_UnusedProductsRepository()),
        autoLoad: false,
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

      const searchKey = ValueKey<String>('home-product-search');

      expect(find.byKey(searchKey), findsOneWidget);

      await tester.enterText(find.byKey(searchKey), 'شاحن');

      await tester.testTextInput.receiveAction(TextInputAction.search);

      await tester.pump();

      expect(productsController.state.search, 'شاحن');
      expect(productsOpened, isTrue);
    },
  );
}

final class _UnusedAuthRepository implements AuthRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

final class _UnusedProductsRepository implements ProductsRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

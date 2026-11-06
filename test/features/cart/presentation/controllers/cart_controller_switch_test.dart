import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  group('CartController switching', () {
    test(
      'switches carts and persists pending writes to the original cart',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final dataSource = CartLocalDataSource(
          database,
          ownerUserId: 'switch-test-user',
        );

        final firstCart = await dataSource.createCart('First cart');
        final secondCart = await dataSource.createCart('Second cart');

        await dataSource.replaceItemsForCart(firstCart.id, [
          const CartItemEntity(product: _firstProduct, quantity: 2),
        ]);

        await dataSource.replaceItemsForCart(secondCart.id, [
          const CartItemEntity(product: _secondProduct, quantity: 3),
        ]);

        await dataSource.setActiveCart(firstCart.id);

        final controller = CartController(localDataSource: dataSource);
        addTearDown(controller.dispose);

        await controller.ready;

        expect(controller.activeCartId, firstCart.id);
        expect(controller.quantityOf(_firstProduct.id), 2);

        // Schedule a write before requesting the switch.
        expect(controller.addProduct(_firstProduct), CartAddResult.added);

        final result = await controller.switchToCart(secondCart.id);

        expect(result, CartSwitchResult.switched);
        expect(controller.activeCartId, secondCart.id);

        expect(controller.quantityOf(_secondProduct.id), 3);
        expect(controller.quantityOf(_firstProduct.id), 0);

        await controller.flushPersistence();

        final firstItems = await dataSource.getItemsForCart(firstCart.id);
        final secondItems = await dataSource.getItemsForCart(secondCart.id);

        expect(firstItems.single.quantity, 3);
        expect(secondItems.single.quantity, 3);

        // Modify the second cart.
        expect(controller.addProduct(_secondProduct), CartAddResult.added);

        await controller.flushPersistence();

        // Return to the first cart.
        final returnResult = await controller.switchToCart(firstCart.id);

        expect(returnResult, CartSwitchResult.switched);
        expect(controller.activeCartId, firstCart.id);
        expect(controller.quantityOf(_firstProduct.id), 3);
        expect(controller.quantityOf(_secondProduct.id), 0);

        final persistedSecondItems = await dataSource.getItemsForCart(
          secondCart.id,
        );

        expect(persistedSecondItems.single.quantity, 4);
      },
    );

    test(
      'rejects foreign and missing carts without changing current state',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final accountA = CartLocalDataSource(
          database,
          ownerUserId: 'account-A',
        );

        final accountB = CartLocalDataSource(
          database,
          ownerUserId: 'account-B',
        );

        final ownedCart = await accountA.createCart('Owned cart');
        final foreignCart = await accountB.createCart('Foreign cart');

        await accountA.replaceItemsForCart(ownedCart.id, [
          const CartItemEntity(product: _firstProduct, quantity: 2),
        ]);

        await accountA.setActiveCart(ownedCart.id);

        final controller = CartController(localDataSource: accountA);
        addTearDown(controller.dispose);

        await controller.ready;

        final foreignResult = await controller.switchToCart(foreignCart.id);

        expect(foreignResult, CartSwitchResult.unavailable);

        final missingResult = await controller.switchToCart('missing-cart');

        expect(missingResult, CartSwitchResult.unavailable);

        expect(controller.activeCartId, ownedCart.id);
        expect(controller.quantityOf(_firstProduct.id), 2);
        expect(await accountA.getActiveCart(), ownedCart);
      },
    );

    test(
      'preserves the old active cart when saving the new selection fails',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final dataSource = CartLocalDataSource(
          database,
          ownerUserId: 'switch-failure-user',
        );

        final firstCart = await dataSource.createCart('First cart');
        final secondCart = await dataSource.createCart('Second cart');

        await dataSource.replaceItemsForCart(firstCart.id, [
          const CartItemEntity(product: _firstProduct, quantity: 2),
        ]);

        await dataSource.setActiveCart(firstCart.id);

        final controller = CartController(localDataSource: dataSource);
        addTearDown(controller.dispose);

        await controller.ready;

        await database.customStatement('''
          CREATE TRIGGER fail_active_cart_selection
          BEFORE INSERT ON cart_active_selection_records
          WHEN NEW.cart_id = '${secondCart.id}'
          BEGIN
            SELECT RAISE(ABORT, 'forced active cart selection failure');
          END;
        ''');

        final result = await controller.switchToCart(secondCart.id);

        expect(result, CartSwitchResult.failed);

        expect(controller.activeCartId, firstCart.id);
        expect(controller.quantityOf(_firstProduct.id), 2);
        expect(await dataSource.getActiveCart(), firstCart);

        await database.customStatement(
          'DROP TRIGGER fail_active_cart_selection;',
        );
      },
    );
  });
}

const _firstProduct = ProductEntity(
  id: 'switch-first-product',
  supplierId: 'supplier-1',
  supplierName: 'Supplier 1',
  name: 'First product',
  price: 1000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

const _secondProduct = ProductEntity(
  id: 'switch-second-product',
  supplierId: 'supplier-2',
  supplierName: 'Supplier 2',
  name: 'Second product',
  price: 2000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  group('CartController switch concurrency', () {
    test(
      'rejects concurrent switching and blocks mutations during switching',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);

        final dataSource = CartLocalDataSource(
          database,
          ownerUserId: 'concurrency-user',
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

        // Start the first switch without awaiting it.
        final firstSwitch = controller.switchToCart(secondCart.id);

        expect(controller.isSwitching, isTrue);

        // A second switch must not replace the first pending transition.
        final competingSwitch = await controller.switchToCart(firstCart.id);

        expect(competingSwitch, CartSwitchResult.busy);

        // All mutations must be rejected while switching.
        expect(controller.addProduct(_thirdProduct), CartAddResult.busy);

        controller.decreaseProduct(_firstProduct.id);
        controller.removeProduct(_firstProduct.id);
        controller.removeProducts([_firstProduct.id, _secondProduct.id]);
        controller.clear();

        final result = await firstSwitch;

        expect(result, CartSwitchResult.switched);
        expect(controller.isSwitching, isFalse);
        expect(controller.activeCartId, secondCart.id);

        // The destination cart must remain unchanged.
        expect(controller.quantityOf(_secondProduct.id), 3);
        expect(controller.quantityOf(_firstProduct.id), 0);
        expect(controller.quantityOf(_thirdProduct.id), 0);

        await controller.flushPersistence();

        final firstItems = await dataSource.getItemsForCart(firstCart.id);
        final secondItems = await dataSource.getItemsForCart(secondCart.id);

        // The original cart was not affected by rejected mutations.
        expect(firstItems.single.quantity, 2);
        expect(firstItems.single.product.id, _firstProduct.id);

        expect(secondItems.single.quantity, 3);
        expect(secondItems.single.product.id, _secondProduct.id);
      },
    );

    test(
      'restores the selected cart and its contents after controller recreation',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);

        final dataSource = CartLocalDataSource(
          database,
          ownerUserId: 'restart-user',
        );

        final firstCart = await dataSource.createCart('First cart');
        final secondCart = await dataSource.createCart('Second cart');

        await dataSource.replaceItemsForCart(firstCart.id, [
          const CartItemEntity(product: _firstProduct, quantity: 4),
        ]);

        await dataSource.replaceItemsForCart(secondCart.id, [
          const CartItemEntity(product: _secondProduct, quantity: 5),
        ]);

        await dataSource.setActiveCart(firstCart.id);

        final firstController = CartController(localDataSource: dataSource);

        await firstController.ready;

        final switchResult = await firstController.switchToCart(secondCart.id);

        expect(switchResult, CartSwitchResult.switched);

        await firstController.flushPersistence();

        expect(firstController.activeCartId, secondCart.id);
        expect(firstController.quantityOf(_secondProduct.id), 5);

        firstController.dispose();

        // Simulate application/controller recreation.
        final restartedDataSource = CartLocalDataSource(
          database,
          ownerUserId: 'restart-user',
        );

        final restartedController = CartController(
          localDataSource: restartedDataSource,
        );

        addTearDown(restartedController.dispose);

        await restartedController.ready;

        expect(restartedController.activeCartId, secondCart.id);
        expect(restartedController.quantityOf(_secondProduct.id), 5);
        expect(restartedController.quantityOf(_firstProduct.id), 0);

        final persistedFirst = await restartedDataSource.getItemsForCart(
          firstCart.id,
        );

        final persistedSecond = await restartedDataSource.getItemsForCart(
          secondCart.id,
        );

        expect(persistedFirst.single.quantity, 4);
        expect(persistedSecond.single.quantity, 5);
      },
    );
  });
}

const _firstProduct = ProductEntity(
  id: 'concurrency-first-product',
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
  id: 'concurrency-second-product',
  supplierId: 'supplier-2',
  supplierName: 'Supplier 2',
  name: 'Second product',
  price: 2000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

const _thirdProduct = ProductEntity(
  id: 'concurrency-third-product',
  supplierId: 'supplier-3',
  supplierName: 'Supplier 3',
  name: 'Third product',
  price: 3000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

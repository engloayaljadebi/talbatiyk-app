import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'adding before restore completes preserves existing persisted products',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final dataSource = CartLocalDataSource(
        database,
        ownerUserId: 'restore-race-test-user',
      );

      final cart = await dataSource.createCart('Restore race test');

      await dataSource.replaceItemsForCart(cart.id, [
        const CartItemEntity(product: _storedProduct, quantity: 2),
      ]);

      await dataSource.setActiveCart(cart.id);

      final controller = CartController(localDataSource: dataSource);

      addTearDown(controller.dispose);

      // Deliberately mutate before awaiting controller.ready.
      expect(controller.addProduct(_newProduct), CartAddResult.added);

      await controller.ready;
      await controller.flushPersistence();

      final persistedItems = await dataSource.getItemsForCart(cart.id);

      final persistedIds = persistedItems
          .map((item) => item.product.id)
          .toSet();

      expect(persistedIds, containsAll([_storedProduct.id, _newProduct.id]));

      expect(
        persistedItems
            .singleWhere((item) => item.product.id == _storedProduct.id)
            .quantity,
        2,
      );

      expect(
        persistedItems
            .singleWhere((item) => item.product.id == _newProduct.id)
            .quantity,
        1,
      );
    },
  );
}

const _storedProduct = ProductEntity(
  id: 'previously-stored-product',
  supplierId: 'supplier-1',
  supplierName: 'Supplier 1',
  name: 'Previously stored product',
  price: 1000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

const _newProduct = ProductEntity(
  id: 'newly-added-product',
  supplierId: 'supplier-2',
  supplierName: 'Supplier 2',
  name: 'Newly added product',
  price: 1500,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

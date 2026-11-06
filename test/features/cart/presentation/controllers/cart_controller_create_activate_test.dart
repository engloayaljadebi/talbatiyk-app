import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'creates and activates a new empty cart while preserving previous items',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final dataSource = CartLocalDataSource(
        database,
        ownerUserId: 'controller-create-activate-user',
      );

      final previous = await dataSource.createCart('السلة السابقة');

      await dataSource.replaceItemsForCart(previous.id, [
        const CartItemEntity(product: _product, quantity: 2),
      ]);

      await dataSource.setActiveCart(previous.id);

      final controller = CartController(localDataSource: dataSource);

      addTearDown(controller.dispose);

      await controller.ready;

      expect(controller.activeCartId, previous.id);
      expect(controller.quantityOf(_product.id), 2);

      // Schedule a pending write against the previous cart.
      expect(controller.addProduct(_product), CartAddResult.added);

      final created = await controller.createCartAndActivate('السلة الجديدة');

      expect(created.name, 'السلة الجديدة');
      expect(controller.activeCartId, created.id);
      expect(controller.isEmpty, isTrue);

      await controller.flushPersistence();

      // The previous cart keeps its saved contents.
      final previousItems = await dataSource.getItemsForCart(previous.id);

      expect(previousItems, hasLength(1));
      expect(previousItems.single.quantity, 3);

      // The new cart starts empty.
      expect(await dataSource.getItemsForCart(created.id), isEmpty);

      expect(await dataSource.getActiveCart(), created);
    },
  );
}

const _product = ProductEntity(
  id: 'create-activate-product',
  supplierId: 'supplier-1',
  supplierName: 'Supplier 1',
  name: 'Create activate test product',
  price: 1500,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

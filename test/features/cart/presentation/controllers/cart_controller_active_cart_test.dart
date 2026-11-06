import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test('controller restores and persists only the selected cart', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);

    final dataSource = CartLocalDataSource(
      database,
      ownerUserId: 'active-cart-test-user',
    );

    final firstCart = await dataSource.createCart('الطلبية الأولى');
    final activeCart = await dataSource.createCart('الطلبية الثانية');

    await dataSource.replaceItemsForCart(firstCart.id, [
      const CartItemEntity(product: _firstProduct, quantity: 2),
    ]);

    await dataSource.replaceItemsForCart(activeCart.id, [
      const CartItemEntity(product: _activeProduct, quantity: 3),
    ]);

    await dataSource.setActiveCart(activeCart.id);

    final controller = CartController(localDataSource: dataSource);

    await controller.ready;

    expect(controller.activeCartId, activeCart.id);
    expect(controller.quantityOf(_activeProduct.id), 3);
    expect(controller.quantityOf(_firstProduct.id), 0);

    expect(controller.addProduct(_activeProduct), CartAddResult.added);

    await controller.flushPersistence();

    final firstItems = await dataSource.getItemsForCart(firstCart.id);
    final activeItems = await dataSource.getItemsForCart(activeCart.id);

    expect(firstItems.single.quantity, 2);
    expect(activeItems.single.quantity, 4);
  });
}

const _firstProduct = ProductEntity(
  id: 'first-cart-product',
  supplierId: 'supplier-1',
  supplierName: 'Supplier 1',
  name: 'First product',
  price: 1000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

const _activeProduct = ProductEntity(
  id: 'active-cart-product',
  supplierId: 'supplier-2',
  supplierName: 'Supplier 2',
  name: 'Active product',
  price: 2000,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

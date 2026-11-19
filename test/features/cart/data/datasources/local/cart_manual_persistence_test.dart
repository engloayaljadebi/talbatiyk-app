import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

CartItemEntity catalogItem(String id, int quantity) {
  return CartItemEntity(
    product: ProductEntity(
      id: id,
      name: 'Catalog $id',
      price: 1500,
      imageUrl: '',
      category: '',
      brand: '',
      isAvailable: true,
    ),
    quantity: quantity,
  );
}

CartItemEntity manualItem(String id, int quantity) {
  return CartItemEntity.manual(
    id: id,
    name: 'Manual item $id',
    unitPrice: 275,
    quantity: quantity,
    unit: 'box',
    note: 'Manual note',
  );
}

void main() {
  late AppDatabase database;
  late CartLocalDataSource accountA;
  late CartLocalDataSource accountB;
  late CartLocalDataSource guest;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    accountA = CartLocalDataSource(database, ownerUserId: 'account-A');
    accountB = CartLocalDataSource(database, ownerUserId: 'account-B');
    guest = CartLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  test('writes and restores catalog and manual items together', () async {
    final cart = await accountA.createCart('Mixed cart');

    await accountA.replaceAllItemsForCart(cart.id, [
      catalogItem('catalog-1', 3),
      manualItem('manual-1', 2),
    ]);

    final items = await accountA.getItemsForCart(cart.id);

    expect(items, hasLength(2));

    final catalog = items.singleWhere((item) => !item.isManual);
    final manual = items.singleWhere((item) => item.isManual);

    expect(catalog.product.id, 'catalog-1');
    expect(catalog.quantity, 3);

    expect(manual.id, 'manual-1');
    expect(manual.product.name, 'Manual item manual-1');
    expect(manual.unitPrice, 275);
    expect(manual.quantity, 2);
    expect(manual.totalPrice, 550);
    expect(manual.unit, 'box');
    expect(manual.note, 'Manual note');
    expect(manual.catalogProductId, isNull);

    final row = await (database.select(
      database.cartItemRecords,
    )..where((table) => table.id.equals('manual-1'))).getSingle();

    expect(row.kind, 'manual');
    expect(row.productId, isNull);
    expect(row.price, 275);
    expect(row.unit, 'box');
    expect(row.note, 'Manual note');
  });

  test('complete snapshot preserves manual identity and other carts', () async {
    final first = await accountA.createCart('First');
    final second = await accountA.createCart('Second');

    await accountA.replaceAllItemsForCart(first.id, [
      catalogItem('catalog-1', 1),
      manualItem('manual-1', 2),
    ]);

    await accountA.replaceAllItemsForCart(second.id, [
      catalogItem('catalog-2', 5),
    ]);

    await accountA.replaceAllItemsForCart(first.id, [
      catalogItem('catalog-1', 4),
      manualItem('manual-1', 7),
    ]);

    final firstItems = await accountA.getItemsForCart(first.id);
    final secondItems = await accountA.getItemsForCart(second.id);

    expect(firstItems, hasLength(2));
    expect(secondItems, hasLength(1));

    final manual = firstItems.singleWhere((item) => item.isManual);

    expect(manual.id, 'manual-1');
    expect(manual.quantity, 7);
    expect(manual.unit, 'box');
    expect(manual.note, 'Manual note');

    expect(secondItems.single.product.id, 'catalog-2');
    expect(secondItems.single.quantity, 5);
  });

  test(
    'rejects foreign and guest writes without damaging saved items',
    () async {
      final owned = await accountA.createCart('Owned');
      final foreign = await accountB.createCart('Foreign');

      await accountA.replaceAllItemsForCart(owned.id, [
        manualItem('manual-preserved', 6),
      ]);

      await expectLater(
        accountA.replaceAllItemsForCart(foreign.id, [
          manualItem('invalid-1', 1),
        ]),
        throwsStateError,
      );

      await expectLater(
        guest.replaceAllItemsForCart(owned.id, [manualItem('invalid-2', 1)]),
        throwsStateError,
      );

      final preserved = await accountA.getItemsForCart(owned.id);

      expect(preserved, hasLength(1));
      expect(preserved.single.id, 'manual-preserved');
      expect(preserved.single.quantity, 6);

      expect(await accountB.getItemsForCart(foreign.id), isEmpty);
    },
  );

  test('controller restores and persists manual item mutations', () async {
    final cart = await accountA.createCart('Controller cart');

    await accountA.replaceAllItemsForCart(cart.id, [
      manualItem('manual-controller', 2),
    ]);

    final controller = CartController(localDataSource: accountA);
    addTearDown(controller.dispose);

    await controller.ready;

    expect(controller.items, hasLength(1));
    expect(controller.items.single.isManual, isTrue);

    final manual = controller.items.single;

    controller.increaseManualItem(manual.id);

    await controller.flushPersistence();

    final restored = await accountA.getItemsForCart(cart.id);

    expect(restored, hasLength(1));
    expect(restored.single.isManual, isTrue);
    expect(restored.single.id, 'manual-controller');
    expect(restored.single.quantity, 3);
    expect(restored.single.unit, 'box');
    expect(restored.single.note, 'Manual note');
  });
}

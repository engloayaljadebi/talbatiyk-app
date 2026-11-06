import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

CartItemEntity item(String id, int quantity) {
  return CartItemEntity(
    product: ProductEntity(
      id: id,
      name: 'Product $id',
      price: 1500,
      imageUrl: '',
      category: '',
      brand: '',
      isAvailable: true,
    ),
    quantity: quantity,
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

  test('writes shared product IDs into separate carts', () async {
    final first = await accountA.createCart('الأولى');
    final second = await accountA.createCart('الثانية');

    await accountA.replaceItemsForCart(first.id, [item('shared-product', 2)]);

    await accountA.replaceItemsForCart(second.id, [item('shared-product', 5)]);

    final firstItems = await accountA.getItemsForCart(first.id);
    final secondItems = await accountA.getItemsForCart(second.id);

    expect(firstItems.single.quantity, 2);
    expect(secondItems.single.quantity, 5);

    expect(firstItems.single.product.id, 'shared-product');
    expect(secondItems.single.product.id, 'shared-product');
  });

  test('captured cart ID stays the write target after switching', () async {
    final first = await accountA.createCart('الأولى');
    final second = await accountA.createCart('الثانية');

    await accountA.setActiveCart(first.id);

    final capturedId = await accountA.resolveCurrentCartId();

    await accountA.setActiveCart(second.id);

    await accountA.replaceItemsForCart(capturedId!, [item('product-a', 3)]);

    expect(
      (await accountA.getItemsForCart(first.id)).single.product.id,
      'product-a',
    );

    expect(await accountA.getItemsForCart(second.id), isEmpty);
    expect(await accountA.getActiveCart(), second);
  });

  test('preserves manual items and other carts during replacement', () async {
    final first = await accountA.createCart('الأولى');
    final second = await accountA.createCart('الثانية');

    await accountA.replaceItemsForCart(first.id, [item('old-product', 1)]);

    await accountA.replaceItemsForCart(second.id, [item('other-product', 4)]);

    final timestamp = DateTime.utc(2026, 11, 4).millisecondsSinceEpoch ~/ 1000;

    await database.customStatement(
      'INSERT INTO cart_item_records '
      '(id, cart_id, kind, product_id, product_name, '
      'price, cart_quantity, sort_order, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
      [
        'manual-sentinel',
        first.id,
        'manual',
        null,
        'Manual item',
        900.0,
        2,
        1,
        timestamp,
      ],
    );

    await accountA.replaceItemsForCart(first.id, [item('new-product', 6)]);

    final firstItems = await accountA.getItemsForCart(first.id);
    final secondItems = await accountA.getItemsForCart(second.id);

    expect(firstItems, hasLength(1));
    expect(firstItems.single.product.id, 'new-product');
    expect(firstItems.single.quantity, 6);

    expect(secondItems, hasLength(1));
    expect(secondItems.single.product.id, 'other-product');
    expect(secondItems.single.quantity, 4);

    final manualRows = await database
        .customSelect(
          "SELECT id, cart_id FROM cart_item_records "
          "WHERE kind = 'manual';",
        )
        .get();

    expect(manualRows, hasLength(1));
    expect(manualRows.single.read<String>('id'), 'manual-sentinel');
    expect(manualRows.single.read<String>('cart_id'), first.id);
  });

  test('rejects foreign, missing and guest writes without damage', () async {
    final owned = await accountA.createCart('سلتي');
    final foreign = await accountB.createCart('سلة أخرى');

    await accountA.replaceItemsForCart(owned.id, [item('preserved', 7)]);

    await expectLater(
      accountA.replaceItemsForCart(foreign.id, [item('bad', 1)]),
      throwsStateError,
    );

    await expectLater(
      accountB.replaceItemsForCart(owned.id, [item('bad', 1)]),
      throwsStateError,
    );

    await expectLater(
      guest.replaceItemsForCart(owned.id, [item('bad', 1)]),
      throwsStateError,
    );

    await expectLater(
      accountA.replaceItemsForCart('missing', [item('bad', 1)]),
      throwsStateError,
    );

    await expectLater(
      accountA.replaceItemsForCart('   ', [item('bad', 1)]),
      throwsArgumentError,
    );

    final preserved = await accountA.getItemsForCart(owned.id);

    expect(preserved, hasLength(1));
    expect(preserved.single.product.id, 'preserved');
    expect(preserved.single.quantity, 7);
    expect(await accountB.getItemsForCart(foreign.id), isEmpty);
  });

  test('replacing items preserves stable IDs for retained products', () async {
    final cart = await accountA.createCart('السلة');

    await accountA.replaceItemsForCart(cart.id, [item('stable-product', 1)]);

    final before = await (database.select(
      database.cartItemRecords,
    )..where((row) => row.cartId.equals(cart.id))).getSingle();

    await accountA.replaceItemsForCart(cart.id, [item('stable-product', 9)]);

    final after = await (database.select(
      database.cartItemRecords,
    )..where((row) => row.cartId.equals(cart.id))).getSingle();

    expect(after.id, before.id);
    expect((await accountA.getItemsForCart(cart.id)).single.quantity, 9);
  });

  test('legacy replaceItems continues targeting the default cart', () async {
    final first = await accountA.createCart('الأولى');
    final second = await accountA.createCart('الثانية');

    await accountA.setActiveCart(second.id);

    await accountA.replaceItems([item('legacy-product', 2)]);

    final firstItems = await accountA.getItemsForCart(first.id);

    expect(firstItems, hasLength(1));
    expect(firstItems.single.product.id, 'legacy-product');

    expect(await accountA.getItemsForCart(second.id), isEmpty);
    expect(await accountA.getActiveCart(), second);
  });
}

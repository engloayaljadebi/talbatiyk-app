import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';

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

  Future<void> insertItem({
    required AppDatabase database,
    required String id,
    required String cartId,
    required String kind,
    required String name,
    String? productId,
  }) async {
    final timestamp = DateTime.utc(2026, 11, 4).millisecondsSinceEpoch ~/ 1000;

    await database.customStatement(
      'INSERT INTO cart_item_records '
      '(id, cart_id, kind, product_id, product_name, '
      'price, cart_quantity, sort_order, updated_at) '
      'VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);',
      [id, cartId, kind, productId, name, 1500.0, 2, 0, timestamp],
    );
  }

  test('reads only catalog items of the requested cart', () async {
    final first = await accountA.createCart('السلة الأولى');
    final second = await accountA.createCart('السلة الثانية');

    await insertItem(
      database: database,
      id: 'row-a',
      cartId: first.id,
      kind: 'catalog',
      productId: 'shared-product',
      name: 'منتج السلة الأولى',
    );

    await insertItem(
      database: database,
      id: 'row-b',
      cartId: second.id,
      kind: 'catalog',
      productId: 'shared-product',
      name: 'منتج السلة الثانية',
    );

    await insertItem(
      database: database,
      id: 'row-manual',
      cartId: second.id,
      kind: 'manual',
      name: 'صنف يدوي محفوظ',
    );

    final firstItems = await accountA.getItemsForCart(first.id);
    final secondItems = await accountA.getItemsForCart(second.id);

    expect(firstItems, hasLength(1));
    expect(secondItems, hasLength(1));

    expect(firstItems.single.product.name, 'منتج السلة الأولى');
    expect(secondItems.single.product.name, 'منتج السلة الثانية');

    expect(firstItems.single.product.id, 'shared-product');
    expect(secondItems.single.product.id, 'shared-product');

    final manualRows = await database
        .customSelect(
          "SELECT COUNT(*) AS total FROM cart_item_records "
          "WHERE kind = 'manual';",
        )
        .getSingle();

    expect(manualRows.read<int>('total'), 1);
    expect(await accountA.getActiveCart(), isNull);
  });

  test('explicit cart ID remains stable after selection changes', () async {
    final first = await accountA.createCart('الأولى');
    final second = await accountA.createCart('الثانية');

    await insertItem(
      database: database,
      id: 'first-item',
      cartId: first.id,
      kind: 'catalog',
      productId: 'product-a',
      name: 'المنتج أ',
    );

    await insertItem(
      database: database,
      id: 'second-item',
      cartId: second.id,
      kind: 'catalog',
      productId: 'product-b',
      name: 'المنتج ب',
    );

    await accountA.setActiveCart(first.id);
    final capturedId = await accountA.resolveCurrentCartId();

    await accountA.setActiveCart(second.id);

    expect(capturedId, first.id);

    final olderOperationItems = await accountA.getItemsForCart(capturedId!);
    final currentOperationItems = await accountA.getItemsForCart(second.id);

    expect(olderOperationItems.single.product.id, 'product-a');
    expect(currentOperationItems.single.product.id, 'product-b');
    expect(await accountA.getActiveCart(), second);
  });

  test('rejects foreign, unknown and guest reads', () async {
    final owned = await accountA.createCart('سلتي');
    final foreign = await accountB.createCart('سلة الحساب الآخر');

    await expectLater(accountA.getItemsForCart(foreign.id), throwsStateError);

    await expectLater(accountB.getItemsForCart(owned.id), throwsStateError);

    await expectLater(guest.getItemsForCart(owned.id), throwsStateError);

    await expectLater(
      accountA.getItemsForCart('does-not-exist'),
      throwsStateError,
    );

    await expectLater(accountA.getItemsForCart('   '), throwsStateError);

    expect(await accountA.listCarts(), [owned]);
    expect(await accountB.listCarts(), [foreign]);
    expect(await accountA.getActiveCart(), isNull);
    expect(await accountB.getActiveCart(), isNull);
  });

  test('empty owned cart returns empty without changing selection', () async {
    final cart = await accountA.createCart('سلة فارغة');

    expect(await accountA.getItemsForCart('  ${cart.id}  '), isEmpty);
    expect(await accountA.getActiveCart(), isNull);

    expect(await accountA.listCarts(), [cart]);
    expect(await database.select(database.cartItemRecords).get(), isEmpty);
  });
}

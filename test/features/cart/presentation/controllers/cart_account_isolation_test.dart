import 'package:drift/drift.dart' show Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test('account carts stay isolated and preserve manual rows', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final accountA = CartLocalDataSource(database, ownerUserId: 'account-A');

    final accountB = CartLocalDataSource(database, ownerUserId: 'account-B');

    final guest = CartLocalDataSource(database);

    const product = ProductEntity(
      id: 'shared-product',
      supplierId: 'supplier-1',
      supplierName: 'Supplier',
      name: 'Shared product',
      price: 1500,
      imageUrl: '',
      category: 'Electronics',
      brand: 'Test',
      isAvailable: true,
    );

    await accountA.replaceItems([
      const CartItemEntity(product: product, quantity: 2),
    ]);

    await accountB.replaceItems([
      const CartItemEntity(product: product, quantity: 5),
    ]);

    expect((await accountA.getItems()).single.quantity, 2);
    expect((await accountB.getItems()).single.quantity, 5);

    final cartA = await database
        .customSelect(
          'SELECT id FROM cart_records WHERE owner_user_id = ?',
          variables: [Variable.withString('account-A')],
        )
        .getSingle();

    final cartAId = cartA.read<String>('id');

    // Simulate an item created by the future manual-entry feature.
    await database.customInsert(
      'INSERT INTO cart_item_records '
      '(id, cart_id, kind, product_id, product_name, '
      'price, cart_quantity, sort_order, updated_at) '
      'VALUES (?, ?, ?, NULL, ?, ?, ?, ?, ?)',
      variables: [
        Variable.withString('manual-item-A'),
        Variable.withString(cartAId),
        Variable.withString('manual'),
        Variable.withString('Manual product'),
        Variable.withReal(500),
        Variable.withInt(3),
        Variable.withInt(1),
        Variable.withInt(1790000000),
      ],
    );

    // Replacing catalog products must not delete manual rows.
    await accountA.replaceItems([
      const CartItemEntity(product: product, quantity: 4),
    ]);

    final manualRows = await database
        .customSelect(
          'SELECT id, product_id, cart_quantity '
          'FROM cart_item_records '
          "WHERE cart_id = ? AND kind = 'manual'",
          variables: [Variable.withString(cartAId)],
        )
        .get();

    expect(manualRows, hasLength(1));
    expect(manualRows.single.read<String>('id'), 'manual-item-A');
    expect(manualRows.single.data['product_id'], isNull);
    expect(manualRows.single.read<int>('cart_quantity'), 3);

    // Clearing account B must not affect account A.
    await accountB.replaceItems([]);

    expect(await accountB.getItems(), isEmpty);
    expect((await accountA.getItems()).single.quantity, 4);

    // No authenticated owner: fail closed.
    expect(await guest.getItems(), isEmpty);

    await expectLater(
      guest.replaceItems([const CartItemEntity(product: product, quantity: 1)]),
      throwsStateError,
    );

    final foreignKeyErrors = await database
        .customSelect('PRAGMA foreign_key_check;')
        .get();

    expect(foreignKeyErrors, isEmpty);
  });
}

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';

void main() {
  test('listCarts isolates owners and does not create carts', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final accountA = CartLocalDataSource(database, ownerUserId: 'account-A');

    final accountB = CartLocalDataSource(database, ownerUserId: 'account-B');

    final guest = CartLocalDataSource(database);

    // Reading an empty account must not create a cart.
    expect(await accountA.listCarts(), isEmpty);
    expect(await accountB.listCarts(), isEmpty);
    expect(await guest.listCarts(), isEmpty);

    Future<void> addCart({
      required String id,
      required String? owner,
      required String name,
      required DateTime createdAt,
    }) async {
      await database
          .into(database.cartRecords)
          .insert(
            CartRecordsCompanion.insert(
              id: id,
              ownerUserId: Value(owner),
              name: name,
              createdAt: createdAt,
              updatedAt: createdAt,
            ),
          );
    }

    await addCart(
      id: 'cart-A-shop',
      owner: 'account-A',
      name: 'طلبية المحل',
      createdAt: DateTime.utc(2026, 11, 1),
    );

    await addCart(
      id: 'cart-B-shop',
      owner: 'account-B',
      name: 'طلبية المحل',
      createdAt: DateTime.utc(2026, 11, 2),
    );

    await addCart(
      id: 'cart-A-client',
      owner: 'account-A',
      name: 'عميل خاص',
      createdAt: DateTime.utc(2026, 11, 3),
    );

    await addCart(
      id: 'legacy-v14-unclaimed',
      owner: null,
      name: 'السلة السابقة',
      createdAt: DateTime.utc(2026, 11, 4),
    );

    expect(await accountA.listCarts(), [
      (id: 'cart-A-shop', name: 'طلبية المحل'),
      (id: 'cart-A-client', name: 'عميل خاص'),
    ]);

    expect(await accountB.listCarts(), [
      (id: 'cart-B-shop', name: 'طلبية المحل'),
    ]);

    expect(await guest.listCarts(), isEmpty);

    // Listing must not add, delete, or claim any existing cart.
    final count = await database
        .customSelect('SELECT COUNT(*) AS total FROM cart_records;')
        .getSingle();

    expect(count.read<int>('total'), 4);

    final legacyOwner = await database
        .customSelect(
          "SELECT owner_user_id FROM cart_records "
          "WHERE id = 'legacy-v14-unclaimed';",
        )
        .getSingle();

    expect(legacyOwner.data['owner_user_id'], isNull);
  });
}

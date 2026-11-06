import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';

void main() {
  test('getOwnedCart accepts only carts owned by current account', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    final accountA = CartLocalDataSource(database, ownerUserId: 'account-A');

    final accountB = CartLocalDataSource(database, ownerUserId: 'account-B');

    final guest = CartLocalDataSource(database);

    // Looking up unknown carts must not create anything.
    expect(await accountA.getOwnedCart('missing'), isNull);
    expect(await guest.getOwnedCart('missing'), isNull);

    final cartA1 = await accountA.createCart('طلبية المحل');
    final cartA2 = await accountA.createCart('عميل خاص');
    final cartB = await accountB.createCart('طلبية المحل');

    expect(await accountA.getOwnedCart(cartA1.id), cartA1);
    expect(await accountA.getOwnedCart(cartA2.id), cartA2);
    expect(await accountB.getOwnedCart(cartB.id), cartB);

    // Foreign account access is denied.
    expect(await accountA.getOwnedCart(cartB.id), isNull);
    expect(await accountB.getOwnedCart(cartA1.id), isNull);
    expect(await accountB.getOwnedCart(cartA2.id), isNull);

    // Unauthenticated access is denied.
    expect(await guest.getOwnedCart(cartA1.id), isNull);
    expect(await guest.getOwnedCart(cartB.id), isNull);

    expect(await accountA.getOwnedCart('  '), isNull);

    final now = DateTime.utc(2026, 11, 4);

    await database
        .into(database.cartRecords)
        .insert(
          CartRecordsCompanion.insert(
            id: 'legacy-v14-unclaimed',
            ownerUserId: const Value(null),
            name: 'السلة السابقة',
            createdAt: now,
            updatedAt: now,
          ),
        );

    // Historical unclaimed data must not be assigned implicitly.
    expect(await accountA.getOwnedCart('legacy-v14-unclaimed'), isNull);

    expect(await accountB.getOwnedCart('legacy-v14-unclaimed'), isNull);

    final count = await database
        .customSelect('SELECT COUNT(*) AS total FROM cart_records;')
        .getSingle();

    expect(count.read<int>('total'), 4);
  });
}

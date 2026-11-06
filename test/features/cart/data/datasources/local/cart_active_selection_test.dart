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

  test('reading an empty selection creates no carts', () async {
    expect(await accountA.getActiveCart(), isNull);
    expect(await accountB.getActiveCart(), isNull);
    expect(await guest.getActiveCart(), isNull);

    expect(await database.select(database.cartRecords).get(), isEmpty);
    expect(
      await database.select(database.cartActiveSelectionRecords).get(),
      isEmpty,
    );
  });

  test('saves independent selections for different accounts', () async {
    final cartA = await accountA.createCart('طلبية المحل');
    final cartB = await accountB.createCart('عميل خاص');

    expect(await accountA.setActiveCart(cartA.id), cartA);
    expect(await accountB.setActiveCart(cartB.id), cartB);

    expect(await accountA.getActiveCart(), cartA);
    expect(await accountB.getActiveCart(), cartB);

    final selections = await database
        .select(database.cartActiveSelectionRecords)
        .get();

    expect(selections, hasLength(2));
    expect(selections.map((row) => row.ownerUserId).toSet(), {
      'account-A',
      'account-B',
    });
  });

  test('switching carts replaces only the active selection', () async {
    final first = await accountA.createCart('السلة الأولى');
    final second = await accountA.createCart('السلة الثانية');

    await accountA.setActiveCart(first.id);
    expect(await accountA.getActiveCart(), first);

    await accountA.setActiveCart(second.id);
    expect(await accountA.getActiveCart(), second);

    final selections = await database
        .select(database.cartActiveSelectionRecords)
        .get();

    expect(selections, hasLength(1));
    expect(selections.single.cartId, second.id);

    final carts = await accountA.listCarts();

    expect(carts, contains(first));
    expect(carts, contains(second));
    expect(carts, hasLength(2));
  });

  test('rejects guest, foreign and invalid cart selections', () async {
    final owned = await accountA.createCart('سلتي');
    final foreign = await accountB.createCart('سلة أخرى');

    await accountA.setActiveCart(owned.id);

    await expectLater(guest.setActiveCart(owned.id), throwsStateError);

    await expectLater(accountA.setActiveCart(foreign.id), throwsStateError);

    await expectLater(
      accountA.setActiveCart('does-not-exist'),
      throwsStateError,
    );

    await expectLater(accountA.setActiveCart('  '), throwsArgumentError);

    expect(await accountA.getActiveCart(), owned);
    expect(await accountB.getActiveCart(), isNull);
    expect(await guest.getActiveCart(), isNull);
  });

  test('restores saved selection in a new data source instance', () async {
    final first = await accountA.createCart('الأولى');
    final second = await accountA.createCart('الثانية');

    await accountA.setActiveCart(first.id);
    await accountA.setActiveCart('  ${second.id}  ');

    final restored = CartLocalDataSource(database, ownerUserId: 'account-A');

    expect(await restored.getActiveCart(), second);
    expect(await accountB.getActiveCart(), isNull);
  });

  test('does not expose a stored selection owned by another account', () async {
    final foreign = await accountB.createCart('سلة الحساب الثاني');

    final timestamp = DateTime.utc(2026, 11, 4).millisecondsSinceEpoch ~/ 1000;

    // Simulates an incorrectly assigned row in the local database.
    await database.customStatement(
      'INSERT INTO cart_active_selection_records '
      '(owner_user_id, cart_id, updated_at) '
      'VALUES (?, ?, ?);',
      ['account-A', foreign.id, timestamp],
    );

    expect(await accountA.getActiveCart(), isNull);
    expect(await accountB.getActiveCart(), isNull);

    final selectionRows = await database
        .select(database.cartActiveSelectionRecords)
        .get();

    // Reading must not silently modify historical data.
    expect(selectionRows, hasLength(1));
  });
}

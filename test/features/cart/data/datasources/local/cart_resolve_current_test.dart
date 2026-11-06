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

  test('guest resolution does not create any cart', () async {
    expect(await guest.resolveCurrentCartId(), isNull);

    expect(await database.select(database.cartRecords).get(), isEmpty);

    expect(
      await database.select(database.cartActiveSelectionRecords).get(),
      isEmpty,
    );
  });

  test('creates one default cart without saving active selection', () async {
    final firstId = await accountA.resolveCurrentCartId();
    final secondId = await accountA.resolveCurrentCartId();

    expect(firstId, isNotNull);
    expect(firstId, secondId);

    final carts = await accountA.listCarts();

    expect(carts, hasLength(1));
    expect(carts.single.id, firstId);
    expect(carts.single.name, 'طلبية المحل');

    expect(await accountA.getActiveCart(), isNull);

    expect(
      await database.select(database.cartActiveSelectionRecords).get(),
      isEmpty,
    );
  });

  test('resolves selected cart and preserves captured identity', () async {
    final first = await accountA.createCart('السلة الأولى');
    final second = await accountA.createCart('السلة الثانية');

    await accountA.setActiveCart(second.id);

    final capturedCartId = await accountA.resolveCurrentCartId();

    expect(capturedCartId, second.id);

    await accountA.setActiveCart(first.id);

    // An earlier operation retains its original target.
    expect(capturedCartId, second.id);

    // New operations resolve the newly selected cart.
    expect(await accountA.resolveCurrentCartId(), first.id);

    final carts = await accountA.listCarts();

    expect(carts, contains(first));
    expect(carts, contains(second));
    expect(carts, hasLength(2));
  });

  test('resolves independently for each account', () async {
    final cartA = await accountA.createCart('طلبية الحساب أ');
    final cartB = await accountB.createCart('طلبية الحساب ب');

    await accountB.setActiveCart(cartB.id);

    expect(await accountA.resolveCurrentCartId(), cartA.id);
    expect(await accountB.resolveCurrentCartId(), cartB.id);

    expect(await accountA.getActiveCart(), isNull);
    expect(await accountB.getActiveCart(), cartB);
  });

  test('does not resolve a foreign active selection', () async {
    final owned = await accountA.createCart('سلتي');
    final foreign = await accountB.createCart('سلة الحساب الآخر');

    final timestamp = DateTime.utc(2026, 11, 4).millisecondsSinceEpoch ~/ 1000;

    await database.customStatement(
      'INSERT INTO cart_active_selection_records '
      '(owner_user_id, cart_id, updated_at) '
      'VALUES (?, ?, ?);',
      ['account-A', foreign.id, timestamp],
    );

    expect(await accountA.getActiveCart(), isNull);

    // An invalid selection falls back to an owned cart.
    expect(await accountA.resolveCurrentCartId(), owned.id);

    // Resolution does not silently rewrite the invalid selection.
    expect(await accountA.getActiveCart(), isNull);
    expect(await accountB.resolveCurrentCartId(), foreign.id);
  });
}

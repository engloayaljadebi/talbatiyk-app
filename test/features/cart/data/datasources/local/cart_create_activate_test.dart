import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';

void main() {
  late AppDatabase database;
  late CartLocalDataSource account;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    account = CartLocalDataSource(
      database,
      ownerUserId: 'create-activate-user',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('creates and activates a new cart atomically', () async {
    final previous = await account.createCart('السلة الحالية');

    await account.setActiveCart(previous.id);

    final created = await account.createCartAndActivate('السلة الجديدة');

    expect(created.id, isNot(previous.id));
    expect(created.name, 'السلة الجديدة');

    expect(await account.getActiveCart(), created);

    expect(await account.listCarts(), unorderedEquals([previous, created]));
  });

  test('rolls back cart creation if active selection fails', () async {
    final previous = await account.createCart('السلة الحالية');

    await account.setActiveCart(previous.id);

    await database.customStatement('''
      CREATE TRIGGER fail_active_cart_selection_insert
      BEFORE INSERT ON cart_active_selection_records
      BEGIN
        SELECT RAISE(ABORT, 'forced active selection failure');
      END;
    ''');

    await expectLater(
      account.createCartAndActivate('سلة يجب التراجع عنها'),
      throwsA(anything),
    );

    expect(await account.listCarts(), [previous]);

    expect(await account.getActiveCart(), previous);

    await database.customStatement(
      'DROP TRIGGER fail_active_cart_selection_insert;',
    );
  });
}

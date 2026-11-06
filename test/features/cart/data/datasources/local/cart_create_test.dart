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

  test('creates independent named carts with unique IDs', () async {
    expect(await accountA.listCarts(), isEmpty);

    final first = await accountA.createCart('  طلبية المحل  ');
    final second = await accountA.createCart('عميل خاص');

    expect(first.name, 'طلبية المحل');
    expect(second.name, 'عميل خاص');
    expect(first.id, isNotEmpty);
    expect(second.id, isNotEmpty);
    expect(first.id, isNot(second.id));

    final uuidPattern = RegExp(
      r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-'
      r'[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
    );

    expect(uuidPattern.hasMatch(first.id), isTrue);
    expect(uuidPattern.hasMatch(second.id), isTrue);

    expect(
      await accountA.listCarts(),
      unorderedEquals([
        (id: first.id, name: 'طلبية المحل'),
        (id: second.id, name: 'عميل خاص'),
      ]),
    );

    expect(await accountB.listCarts(), isEmpty);
  });

  test('rejects blank names and names over 60 characters', () async {
    await expectLater(accountA.createCart('   '), throwsArgumentError);

    await expectLater(accountA.createCart(''), throwsArgumentError);

    final maximumName = List.filled(60, 'س').join();
    final tooLongName = List.filled(61, 'س').join();

    final validCart = await accountA.createCart(maximumName);

    expect(validCart.name, maximumName);

    await expectLater(accountA.createCart(tooLongName), throwsArgumentError);

    expect(await accountA.listCarts(), [(id: validCart.id, name: maximumName)]);
  });

  test('rejects duplicate names within the same account', () async {
    final original = await accountA.createCart('Workshop');

    await expectLater(accountA.createCart(' workshop '), throwsStateError);

    await expectLater(accountA.createCart('WORKSHOP'), throwsStateError);

    expect(await accountA.listCarts(), [(id: original.id, name: 'Workshop')]);
  });

  test('allows the same name for different accounts', () async {
    final first = await accountA.createCart('طلبية المحل');
    final second = await accountB.createCart('طلبية المحل');

    expect(first.id, isNot(second.id));

    expect(await accountA.listCarts(), [(id: first.id, name: first.name)]);

    expect(await accountB.listCarts(), [(id: second.id, name: second.name)]);

    final rows = await database
        .customSelect(
          'SELECT id, owner_user_id FROM cart_records '
          'ORDER BY owner_user_id',
        )
        .get();

    expect(rows, hasLength(2));
    expect(rows[0].read<String>('owner_user_id'), 'account-A');
    expect(rows[1].read<String>('owner_user_id'), 'account-B');
  });

  test('rejects guest creation without modifying stored carts', () async {
    await expectLater(guest.createCart('سلة غير مصرح بها'), throwsStateError);

    expect(await guest.listCarts(), isEmpty);

    final count = await database
        .customSelect('SELECT COUNT(*) AS total FROM cart_records')
        .getSingle();

    expect(count.read<int>('total'), 0);
  });
}

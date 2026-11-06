import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';

void main() {
  test(
    'cartListProvider returns only carts belonging to its account',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final ownerDataSource = CartLocalDataSource(
        database,
        ownerUserId: 'cart-list-owner',
      );

      final otherDataSource = CartLocalDataSource(
        database,
        ownerUserId: 'cart-list-other',
      );

      final first = await ownerDataSource.createCart('السلة الأولى');
      final second = await ownerDataSource.createCart('السلة الثانية');

      await otherDataSource.createCart('سلة حساب آخر');

      final container = ProviderContainer(
        overrides: [
          cartLocalDataSourceProvider.overrideWithValue(ownerDataSource),
        ],
      );

      addTearDown(container.dispose);

      final result = await container.read(cartListProvider.future);

      expect(result, unorderedEquals([first, second]));

      final third = await ownerDataSource.createCart('السلة الثالثة');

      container.invalidate(cartListProvider);

      final refreshed = await container.read(cartListProvider.future);

      expect(
        refreshed.map((cart) => cart.id),
        unorderedEquals([first.id, second.id, third.id]),
      );
    },
  );
}

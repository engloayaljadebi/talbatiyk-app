import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbatiyk/features/auth/presentation/providers/account_session_fence_provider.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';

void main() {
  group('Riverpod local order account ownership', () {
    test('new order and outbox are owned by authenticated account A', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      AuthSessionEntity? active = _session('account-A');

      final fence = AccountSessionFence(() => active);

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountSessionFenceProvider.overrideWithValue(fence),
        ],
      );

      addTearDown(container.dispose);

      final local = container.read(ordersLocalDataSourceProvider);

      final order = await local.createOrder(_request());

      final orderRows = await database.select(database.orderRecords).get();

      final operations = await database.select(database.syncOperations).get();

      expect(orderRows, hasLength(1));
      expect(operations, hasLength(1));

      expect(orderRows.single.id, order.id);

      expect(
        orderRows.single.ownerUserId,
        'account-A',
        reason: 'Order ownership must be stored durably.',
      );

      expect(
        operations.single.ownerUserId,
        'account-A',
        reason: 'Outbox ownership must match the order owner.',
      );
    });

    test(
      'switching from A to B hides A orders without deleting them',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        AuthSessionEntity? active = _session('account-A');

        final fence = AccountSessionFence(() => active);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            accountSessionFenceProvider.overrideWithValue(fence),
          ],
        );

        addTearDown(container.dispose);

        final local = container.read(ordersLocalDataSourceProvider);

        final orderA = await local.createOrder(_request());

        expect(await local.getOrders(), hasLength(1));

        active = _session('account-B');

        final visibleToB = await local.getOrders();

        expect(
          visibleToB,
          isEmpty,
          reason: 'Account B must not see account A orders.',
        );

        final preservedOrders = await database
            .select(database.orderRecords)
            .get();

        final preservedOutbox = await database
            .select(database.syncOperations)
            .get();

        expect(preservedOrders, hasLength(1));
        expect(preservedOrders.single.id, orderA.id);
        expect(preservedOutbox, hasLength(1));
      },
    );

    test(
      'creating an order without a session is rejected before persistence',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());

        addTearDown(database.close);

        final fence = AccountSessionFence(() => null);

        final container = ProviderContainer(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            accountSessionFenceProvider.overrideWithValue(fence),
          ],
        );

        addTearDown(container.dispose);

        final local = container.read(ordersLocalDataSourceProvider);

        await expectLater(local.createOrder(_request()), throwsStateError);

        expect(await database.select(database.orderRecords).get(), isEmpty);

        expect(await database.select(database.syncOperations).get(), isEmpty);
      },
    );
  });
}

AuthSessionEntity _session(String userId) {
  return AuthSessionEntity(
    user: AuthUserEntity(
      id: userId,
      username: 'test-user',
      displayName: 'Test User',
      status: 'active',
      lastLoginAt: null,
      contacts: const <AuthContactEntity>[],
    ),
  );
}

CreateOrderModel _request() {
  return CreateOrderModel(
    supplierIds: const <String>['supplier-1'],
    notes: 'Account-owned offline order',
    items: const <OrderItemModel>[
      OrderItemModel(
        productId: 'product-1',
        productName: 'Private product',
        unitPrice: 100,
        quantity: 1,
        supplierId: 'supplier-1',
        supplierName: 'Supplier 1',
      ),
    ],
  );
}

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbatiyk/features/auth/presentation/providers/account_session_fence_provider.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';

void main() {
  group('Cross-account local order mutation isolation', () {
    late AppDatabase database;
    late ProviderContainer container;
    late OrdersLocalDataSource local;
    late AuthSessionEntity? activeSession;

    setUp(() {
      database = AppDatabase.forTesting(NativeDatabase.memory());

      activeSession = _session('account-A');

      final fence = AccountSessionFence(() => activeSession);

      container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountSessionFenceProvider.overrideWithValue(fence),
        ],
      );

      local = container.read(ordersLocalDataSourceProvider);
    });

    tearDown(() async {
      container.dispose();
      await database.close();
    });

    test('B cannot discard A pending create or remove its outbox', () async {
      final orderA = await local.createOrder(_request());
      final operationId = 'order:create:${orderA.id}';

      activeSession = _session('account-B');

      await expectLater(
        local.discardPendingCreate(
          localOrderId: orderA.id,
          operationId: operationId,
        ),
        throwsStateError,
      );

      final rows = await database.select(database.orderRecords).get();

      final outbox = await database.select(database.syncOperations).get();

      expect(rows, hasLength(1));
      expect(rows.single.id, orderA.id);
      expect(rows.single.ownerUserId, 'account-A');

      expect(outbox, hasLength(1));
      expect(outbox.single.id, operationId);
      expect(outbox.single.ownerUserId, 'account-A');
    });

    test('B cannot reconcile A pending create as B server order', () async {
      final orderA = await local.createOrder(_request());
      final operationId = 'order:create:${orderA.id}';

      final remoteOrder = orderA.copyWith(
        id: 'server-order-for-A',
        status: 'accepted',
      );

      activeSession = _session('account-B');

      await expectLater(
        local.completeCreateSync(
          localOrderId: orderA.id,
          operationId: operationId,
          remoteOrder: remoteOrder,
        ),
        throwsStateError,
      );

      final orders = await database.select(database.orderRecords).get();

      final outbox = await database.select(database.syncOperations).get();

      expect(orders, hasLength(1));
      expect(orders.single.id, orderA.id);
      expect(orders.single.ownerUserId, 'account-A');

      expect(outbox, hasLength(1));
      expect(outbox.single.id, operationId);
      expect(outbox.single.ownerUserId, 'account-A');
    });

    test('B cannot mark A outbox as retrying', () async {
      final orderA = await local.createOrder(_request());
      final operationId = 'order:create:${orderA.id}';

      activeSession = _session('account-B');

      await expectLater(
        local.markCreateSyncRetry(
          operationId: operationId,
          attempts: 3,
          error: StateError('Simulated transport failure'),
          nextAttemptAt: DateTime.utc(2026, 10, 14),
        ),
        throwsStateError,
      );

      final operation = await (database.select(
        database.syncOperations,
      )..where((table) => table.id.equals(operationId))).getSingle();

      expect(operation.ownerUserId, 'account-A');
      expect(operation.attempts, 0);
      expect(operation.status, SyncOperationStatuses.pending);
    });

    test('B cannot mark A outbox as permanent failure', () async {
      final orderA = await local.createOrder(_request());
      final operationId = 'order:create:${orderA.id}';

      activeSession = _session('account-B');

      await expectLater(
        local.markCreateSyncPermanentFailure(
          operationId: operationId,
          attempts: 2,
          error: const FormatException('Simulated invalid payload'),
        ),
        throwsStateError,
      );

      final operation = await (database.select(
        database.syncOperations,
      )..where((table) => table.id.equals(operationId))).getSingle();

      expect(operation.ownerUserId, 'account-A');
      expect(operation.attempts, 0);
      expect(operation.status, SyncOperationStatuses.pending);
    });

    test('B cannot update A aggregate order status', () async {
      final orderA = _serverOrder('server-order-owned-by-A');

      await local.saveOrder(orderA);

      activeSession = _session('account-B');

      await expectLater(
        local.updateAggregateStatusSnapshot(
          orderId: orderA.id,
          aggregateStatus: 'delivered',
        ),
        throwsStateError,
      );

      final row = await (database.select(
        database.orderRecords,
      )..where((table) => table.id.equals(orderA.id))).getSingle();

      expect(row.ownerUserId, 'account-A');
      expect(row.aggregateStatus, 'pending_responses');
    });

    test(
      'B empty server snapshot cannot delete A server-owned cache',
      () async {
        final orderA = _serverOrder('server-order-owned-by-A');

        await local.saveOrder(orderA);

        activeSession = _session('account-B');

        await local.replaceServerSnapshotPreservingPendingCreates(
          const <OrderModel>[],
        );

        final rows = await database.select(database.orderRecords).get();

        expect(
          rows,
          hasLength(1),
          reason: 'Reconciliation must preserve other accounts.',
        );

        expect(rows.single.id, orderA.id);
        expect(rows.single.ownerUserId, 'account-A');
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
    notes: 'Offline order belonging to account A',
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

OrderModel _serverOrder(String id) {
  return OrderModel(
    id: id,
    status: 'accepted',
    items: _request().items,
    createdAt: DateTime.utc(2026, 10, 12),
    notes: 'Account A server-owned order',
  );
}

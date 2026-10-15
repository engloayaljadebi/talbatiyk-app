import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/sync/orders_sync_coordinator.dart';

void main() {
  group('Cross-account offline order isolation', () {
    test('account B must not read account A pending orders', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      // Account A creates an order while offline.
      final accountALocal = OrdersLocalDataSource(
        database,
        sessionFence: _accountFence('account-A'),
      );

      final orderA = await accountALocal.createOrder(_sampleOrderRequest());

      expect(orderA.id, startsWith('local-order-'));

      // Simulate account switch on the same device.
      // The current datasource API does not accept account identity.
      final accountBLocal = OrdersLocalDataSource(
        database,
        sessionFence: _accountFence('account-B'),
      );

      final visibleToB = await accountBLocal.getOrders();

      expect(
        visibleToB,
        isEmpty,
        reason: 'Account B must not see account A locally stored orders.',
      );
    });

    test('account B must not replay account A queued order', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      // Account A creates a durable offline order and Outbox record.
      final accountALocal = OrdersLocalDataSource(
        database,
        sessionFence: _accountFence('account-A'),
      );

      final orderA = await accountALocal.createOrder(_sampleOrderRequest());

      final operationsBefore = await database
          .select(database.syncOperations)
          .get();

      expect(operationsBefore, hasLength(1));
      expect(operationsBefore.single.entityId, orderA.id);
      expect(operationsBefore.single.ownerUserId, 'account-A');

      // Account B subsequently becomes the authenticated user.
      // This fake represents a remote datasource using B's token.
      final accountBRemote = _RecordingAccountRemote(
        authenticatedAccountId: 'account-B',
      );

      final coordinatorForB = OrdersSyncCoordinator(
        sessionFence: _accountFence('account-B'),
        database: database,
        localDataSource: OrdersLocalDataSource(
          database,
          sessionFence: _accountFence('account-B'),
        ),
        remoteDataSource: accountBRemote,
      );

      await coordinatorForB.syncPendingOrders();

      expect(
        accountBRemote.createAttempts,
        isEmpty,
        reason:
            'An Outbox operation created by account A must never '
            'be sent using account B authentication.',
      );

      final operationsAfter = await database
          .select(database.syncOperations)
          .get();

      expect(
        operationsAfter,
        hasLength(1),
        reason: 'The queued order must be preserved for its owner.',
      );
    });
    test('legacy unowned Outbox must not be sent under account A', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final accountFence = _accountFence('account-A');

      final local = OrdersLocalDataSource(database, sessionFence: accountFence);

      final order = await local.createOrder(_sampleOrderRequest());
      final operationId = 'order:create:${order.id}';

      // Simulate an intact historical Outbox entry whose owner is unknown.
      // Preserve the order and its payload: only clear ownership.
      await (database.update(
        database.syncOperations,
      )..where((table) => table.id.equals(operationId))).write(
        const SyncOperationsCompanion(ownerUserId: Value<String?>(null)),
      );

      final before = await (database.select(
        database.syncOperations,
      )..where((table) => table.id.equals(operationId))).getSingle();

      expect(before.ownerUserId, isNull);

      final remote = _RecordingAccountRemote(
        authenticatedAccountId: 'account-A',
      );

      final coordinator = OrdersSyncCoordinator(
        sessionFence: accountFence,
        database: database,
        localDataSource: local,
        remoteDataSource: remote,
      );

      await coordinator.syncPendingOrders();

      expect(
        remote.createAttempts,
        isEmpty,
        reason: 'Unknown ownership must never be guessed.',
      );

      final orders = await database.select(database.orderRecords).get();
      final outbox = await database.select(database.syncOperations).get();

      expect(orders, hasLength(1));
      expect(orders.single.id, order.id);
      expect(outbox, hasLength(1));
      expect(outbox.single.id, operationId);
      expect(outbox.single.ownerUserId, isNull);
    });
  });
}

AccountSessionFence _accountFence(String accountId) {
  final session = AuthSessionEntity(
    user: AuthUserEntity(
      id: accountId,
      username: 'security-test-user',
      displayName: 'Security Test User',
      status: 'active',
      lastLoginAt: null,
      contacts: const <AuthContactEntity>[],
    ),
  );

  return AccountSessionFence(() => session);
}

CreateOrderModel _sampleOrderRequest() {
  return CreateOrderModel(
    supplierIds: const ['supplier-1'],
    notes: 'Private offline order created by account A',
    items: const [
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

final class _RecordingAccountRemote implements OrdersDataSource {
  _RecordingAccountRemote({required this.authenticatedAccountId});

  final String authenticatedAccountId;

  final List<String> createAttempts = <String>[];

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    createAttempts.add(authenticatedAccountId);

    return OrderModel(
      id: 'server-order-created-as-$authenticatedAccountId',
      status: 'pending',
      createdAt: DateTime.utc(2026, 10, 13),
      notes: request.notes,
      items: request.items,
    );
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    return <OrderModel>[];
  }
}

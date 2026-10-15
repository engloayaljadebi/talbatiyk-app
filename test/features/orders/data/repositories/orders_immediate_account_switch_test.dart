import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbatiyk/features/orders/data/datasources/local/orders_local_datasource.dart';
import 'package:talbatiyk/features/orders/data/datasources/orders_datasource.dart';
import 'package:talbatiyk/features/orders/data/models/orders_model.dart';
import 'package:talbatiyk/features/orders/data/repositories/orders_repository_impl.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';

void main() {
  group('Immediate order account-switch protection', () {
    test('switch after local persistence prevents remote submission', () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      AuthSessionEntity? active = _session('account-A');
      final fence = AccountSessionFence(() => active);

      final local = _SwitchAfterLocalCreate(
        database,
        sessionFence: fence,
        onCreated: () {
          active = _session('account-B');
        },
      );

      final remote = _RecordingRemote();

      final repository = OrdersRepositoryImpl(
        local,
        sessionFence: fence,
        remoteDataSource: remote,
      );

      await expectLater(repository.createOrder(_request()), throwsStateError);

      expect(
        remote.createCalls,
        0,
        reason: 'An A-owned order must not be sent after B signs in.',
      );

      await _expectPreservedPendingA(database);
    });

    test(
      'switch during remote completion preserves A order and Outbox',
      () async {
        final database = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(database.close);

        AuthSessionEntity? active = _session('account-A');
        final fence = AccountSessionFence(() => active);

        final local = OrdersLocalDataSource(database, sessionFence: fence);

        final remote = _RecordingRemote(
          onCreate: () {
            // Simulate account change while awaiting the network response.
            active = _session('account-B');
          },
        );

        final repository = OrdersRepositoryImpl(
          local,
          sessionFence: fence,
          remoteDataSource: remote,
        );

        await expectLater(repository.createOrder(_request()), throwsStateError);

        expect(remote.createCalls, 1);

        await _expectPreservedPendingA(database);
      },
    );
  });
}

class _SwitchAfterLocalCreate extends OrdersLocalDataSource {
  _SwitchAfterLocalCreate(
    super.database, {
    required super.sessionFence,
    required this.onCreated,
  });

  final void Function() onCreated;

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    final order = await super.createOrder(request);

    // Deterministic switch at the exact boundary before Repository
    // resumes and attempts the first HTTP submission.
    onCreated();

    return order;
  }
}

class _RecordingRemote implements OrdersDataSource {
  _RecordingRemote({this.onCreate});

  final void Function()? onCreate;
  int createCalls = 0;

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    createCalls++;
    onCreate?.call();

    return OrderModel(
      id: 'server-order-$createCalls',
      status: 'pending',
      items: request.items,
      createdAt: DateTime.utc(2026, 10, 13),
      notes: request.notes,
    );
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    return <OrderModel>[];
  }
}

AuthSessionEntity _session(String accountId) {
  return AuthSessionEntity(
    user: AuthUserEntity(
      id: accountId,
      username: 'security-test-user',
      displayName: 'Security Test User',
      status: 'active',
      lastLoginAt: null,
      contacts: const <AuthContactEntity>[],
    ),
  );
}

CreateOrderRequest _request() {
  return CreateOrderRequest(
    supplierIds: const <String>['supplier-1'],
    notes: 'Private order owned by account A',
    items: const <OrderItemEntity>[
      OrderItemEntity(
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

Future<void> _expectPreservedPendingA(AppDatabase database) async {
  final orders = await database.select(database.orderRecords).get();
  final outbox = await database.select(database.syncOperations).get();

  expect(orders, hasLength(1));
  expect(orders.single.ownerUserId, 'account-A');
  expect(orders.single.id, startsWith('local-order-'));

  expect(outbox, hasLength(1));
  expect(outbox.single.ownerUserId, 'account-A');
  expect(outbox.single.entityId, orders.single.id);
  expect(outbox.single.status, SyncOperationStatuses.pending);
  expect(outbox.single.attempts, 0);
}

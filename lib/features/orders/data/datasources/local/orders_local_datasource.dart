import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../../auth/domain/services/account_session_fence.dart';
import '../../models/orders_model.dart';
import 'package:uuid/uuid.dart';
import '../orders_datasource.dart';

class OrdersLocalDataSource implements OrdersDataSource {
  OrdersLocalDataSource(
    this._database, {
    required this._sessionFence,
  });

  final AppDatabase _database;
  final AccountSessionFence _sessionFence;

  @override
  Future<List<OrderModel>> getOrders() async {
    final lease = _sessionFence.capture();

    final List<OrderRecord> orderRows =
        await (_database.select(_database.orderRecords)
              ..where(
                (OrderRecords table) =>
                    table.ownerUserId.equals(lease.ownerUserId),
              )
              ..orderBy([
                (OrderRecords table) => OrderingTerm.desc(table.createdAt),
              ]))
            .get();

    lease.ensureCurrent();

    final List<OrderModel> orders = [];

    for (final OrderRecord orderRow in orderRows) {
      final List<OrderItemRecord> itemRows =
          await (_database.select(_database.orderItemRecords)..where(
                (OrderItemRecords table) => table.orderId.equals(orderRow.id),
              ))
              .get();

      lease.ensureCurrent();

      orders.add(
        OrderModel(
          id: orderRow.id,
          status: orderRow.status,
          aggregateStatus: orderRow.aggregateStatus,
          items: itemRows.map(_itemRecordToModel).toList(growable: false),
          createdAt: orderRow.createdAt.toUtc(),
          notes: orderRow.notes,
        ),
      );
    }

    lease.ensureCurrent();
    return List<OrderModel>.unmodifiable(orders);
  }

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    final lease = _sessionFence.capture();

    final CreateOrderModel queuedRequest = request.idempotencyKey.trim().isEmpty
        ? request.copyWith(idempotencyKey: Uuid().v4())
        : request;
    final DateTime now = DateTime.now().toUtc();
    final String orderId = 'local-order-${now.microsecondsSinceEpoch}';

    final OrderModel order = OrderModel(
      id: orderId,
      status: 'pending',
      aggregateStatus: 'pending_responses',
      items: queuedRequest.items,
      createdAt: now,
      notes: queuedRequest.notes,
    );

    await _database.transaction(() async {
      // يجب أن يبقى الطلب المحلي والـOutbox في transaction واحدة:
      // إما أن يُحفَظ الاثنان أو لا يُحفَظ أي منهما.
      lease.ensureCurrent();

      await _saveOrderRows(
        order,
        updatedAt: now,
        ownerUserId: lease.ownerUserId,
      );

      lease.ensureCurrent();

      await _database
          .into(_database.syncOperations)
          .insertOnConflictUpdate(
            SyncOperationsCompanion.insert(
              id: 'order:create:$orderId',
              ownerUserId: Value(lease.ownerUserId),
              entityType: 'order',
              entityId: orderId,
              operation: 'create',
              payloadJson: jsonEncode(_createOrderPayload(queuedRequest)),
              createdAt: now,
            ),
          );

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
    return order;
  }

  /// Persists an order using its existing ID.
  ///
  /// This is used after successful remote creation so the
  /// server-generated order ID is preserved locally.
  Future<OrderModel> saveOrder(OrderModel order) async {
    final lease = _sessionFence.capture();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      lease.ensureCurrent();

      await _saveOrderRows(
        order,
        updatedAt: now,
        ownerUserId: lease.ownerUserId,
      );

      lease.ensureCurrent();
    });

    lease.ensureCurrent();

    return OrderModel(
      id: order.id,
      status: order.status,
      aggregateStatus: order.aggregateStatus,
      items: order.items,
      createdAt: order.createdAt.toUtc(),
      notes: order.notes,
    );
  }

  /// Replaces the temporary offline order with the authoritative server order
  /// and removes its completed Outbox operation atomically.
  Future<OrderModel> completeCreateSync({
    required String localOrderId,
    required String operationId,
    required OrderModel remoteOrder,
  }) async {
    final lease = _sessionFence.capture();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _requireOwnedCreateOutbox(
        lease: lease,
        orderId: localOrderId,
        operationId: operationId,
      );

      lease.ensureCurrent();

      await (_database.delete(
        _database.orderItemRecords,
      )..where((table) => table.orderId.equals(localOrderId))).go();

      await (_database.delete(_database.orderRecords)..where(
            (table) =>
                table.id.equals(localOrderId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .go();

      lease.ensureCurrent();

      await _saveOrderRows(
        remoteOrder,
        updatedAt: now,
        ownerUserId: lease.ownerUserId,
      );

      await (_database.delete(_database.syncOperations)..where(
            (table) =>
                table.id.equals(operationId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .go();

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
    return remoteOrder;
  }

  /// Removes a locally queued create after a definitive server rejection.
  ///
  /// The temporary order and its Outbox operation must disappear atomically
  /// so a permanently rejected logical request cannot be replayed later.
  Future<void> discardPendingCreate({
    required String localOrderId,
    required String operationId,
  }) async {
    final lease = _sessionFence.capture();

    await _database.transaction(() async {
      await _requireOwnedCreateOutbox(
        lease: lease,
        orderId: localOrderId,
        operationId: operationId,
      );

      lease.ensureCurrent();

      await (_database.delete(
        _database.orderItemRecords,
      )..where((table) => table.orderId.equals(localOrderId))).go();

      await (_database.delete(_database.orderRecords)..where(
            (table) =>
                table.id.equals(localOrderId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .go();

      await (_database.delete(_database.syncOperations)..where(
            (table) =>
                table.id.equals(operationId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .go();

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
  }

  /// يسجل فشلًا مؤقتًا مع موعد المحاولة التالية.
  ///
  /// نبقي العملية قابلة للمزامنة لأن السبب قد يختفي بدون تغيير
  /// نفس العملية المنطقية أو الـidempotency key.
  Future<void> markCreateSyncRetry({
    required String operationId,
    required int attempts,
    required Object error,
    required DateTime nextAttemptAt,
  }) async {
    final lease = _sessionFence.capture();

    await _database.transaction(() async {
      await _requireOwnedCreateOperation(
        lease: lease,
        operationId: operationId,
      );

      lease.ensureCurrent();

      await (_database.update(_database.syncOperations)..where(
            (table) =>
                table.id.equals(operationId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .write(
            SyncOperationsCompanion(
              status: const Value(SyncOperationStatuses.retrying),
              attempts: Value(attempts),
              lastError: Value(error.toString()),
              nextAttemptAt: Value(nextAttemptAt.toUtc()),
            ),
          );

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
  }

  /// يسجل failure نهائيًا بدون حذف الـOrder أو الـOutbox.
  ///
  /// الاحتفاظ بالعملية مهم حتى لا يتحول فشل المزامنة إلى Data Loss.
  /// nextAttemptAt يُمسح لأن هذه العملية لا يجب أن تُعاد تلقائيًا.
  Future<void> markCreateSyncPermanentFailure({
    required String operationId,
    required int attempts,
    required Object error,
  }) async {
    final lease = _sessionFence.capture();

    await _database.transaction(() async {
      await _requireOwnedCreateOperation(
        lease: lease,
        operationId: operationId,
      );

      lease.ensureCurrent();

      await (_database.update(_database.syncOperations)..where(
            (table) =>
                table.id.equals(operationId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .write(
            SyncOperationsCompanion(
              status: const Value(SyncOperationStatuses.permanentFailure),
              attempts: Value(attempts),
              lastError: Value(error.toString()),
              nextAttemptAt: const Value<DateTime?>(null),
            ),
          );

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
  }

  /// Reconciles the complete server-owned order snapshot atomically.
  ///
  /// Local create operations with a durable Outbox row are protected because
  /// they may not exist on the server yet. All other local orders are treated
  /// as server-owned snapshots and are removed when absent from the current
  /// authenticated user's authoritative response.
  Future<void> replaceServerSnapshotPreservingPendingCreates(
    List<OrderModel> serverOrders,
  ) async {
    final lease = _sessionFence.capture();

    final snapshot = List<OrderModel>.unmodifiable(serverOrders);
    final serverOrderIds = snapshot.map((order) => order.id).toSet();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      lease.ensureCurrent();

      final pendingCreates =
          await (_database.select(_database.syncOperations)..where(
                (table) =>
                    table.entityType.equals('order') &
                    table.operation.equals('create') &
                    table.ownerUserId.equals(lease.ownerUserId),
              ))
              .get();

      lease.ensureCurrent();

      final protectedLocalOrderIds = pendingCreates
          .map((operation) => operation.entityId)
          .toSet();

      final existingOrders = await (_database.select(
        _database.orderRecords,
      )..where((table) => table.ownerUserId.equals(lease.ownerUserId))).get();

      lease.ensureCurrent();

      final staleServerOrderIds = existingOrders
          .map((order) => order.id)
          .where(
            (orderId) =>
                !serverOrderIds.contains(orderId) &&
                !protectedLocalOrderIds.contains(orderId),
          )
          .toList(growable: false);

      if (staleServerOrderIds.isNotEmpty) {
        await (_database.delete(
          _database.orderItemRecords,
        )..where((table) => table.orderId.isIn(staleServerOrderIds))).go();

        await (_database.delete(_database.orderRecords)..where(
              (table) =>
                  table.id.isIn(staleServerOrderIds) &
                  table.ownerUserId.equals(lease.ownerUserId),
            ))
            .go();
      }

      for (final order in snapshot) {
        lease.ensureCurrent();

        await _saveOrderRows(
          order,
          updatedAt: now,
          ownerUserId: lease.ownerUserId,
        );
      }

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
  }

  /// Updates only the last known server-authoritative aggregate lifecycle.
  ///
  /// A missing local row is intentionally a no-op: comparison data can still
  /// be viewed even when the order is not present in this local database.
  Future<void> updateAggregateStatusSnapshot({
    required String orderId,
    required String aggregateStatus,
  }) async {
    final lease = _sessionFence.capture();
    final now = DateTime.now().toUtc();

    await _database.transaction(() async {
      lease.ensureCurrent();

      final existing = await (_database.select(
        _database.orderRecords,
      )..where((table) => table.id.equals(orderId))).getSingleOrNull();

      lease.ensureCurrent();

      // Preserve the original no-op semantics for an absent order.
      if (existing == null) {
        return;
      }

      if (existing.ownerUserId != lease.ownerUserId) {
        throw StateError(
          'Refusing to update an order owned by another or unknown account.',
        );
      }

      await (_database.update(_database.orderRecords)..where(
            (table) =>
                table.id.equals(orderId) &
                table.ownerUserId.equals(lease.ownerUserId),
          ))
          .write(
            OrderRecordsCompanion(
              aggregateStatus: Value(aggregateStatus),
              updatedAt: Value(now),
            ),
          );

      lease.ensureCurrent();
    });

    lease.ensureCurrent();
  }

  Future<void> _requireOwnedCreateOutbox({
    required AccountSessionLease lease,
    required String orderId,
    required String operationId,
  }) async {
    lease.ensureCurrent();

    final order = await (_database.select(
      _database.orderRecords,
    )..where((table) => table.id.equals(orderId))).getSingleOrNull();

    lease.ensureCurrent();

    final operation = await (_database.select(
      _database.syncOperations,
    )..where((table) => table.id.equals(operationId))).getSingleOrNull();

    lease.ensureCurrent();

    if (order?.ownerUserId != lease.ownerUserId ||
        operation?.ownerUserId != lease.ownerUserId ||
        operation?.entityType != 'order' ||
        operation?.operation != 'create' ||
        operation?.entityId != orderId) {
      throw StateError(
        'Refusing to mutate an order or outbox not owned by this session.',
      );
    }
  }

  Future<void> _requireOwnedCreateOperation({
    required AccountSessionLease lease,
    required String operationId,
  }) async {
    lease.ensureCurrent();

    final operation = await (_database.select(
      _database.syncOperations,
    )..where((table) => table.id.equals(operationId))).getSingleOrNull();

    lease.ensureCurrent();

    if (operation?.ownerUserId != lease.ownerUserId ||
        operation?.entityType != 'order' ||
        operation?.operation != 'create') {
      throw StateError(
        'Refusing to modify an outbox owned by another or unknown account.',
      );
    }
  }

  Future<void> _saveOrderRows(
    OrderModel order, {
    required DateTime updatedAt,
    String? ownerUserId,
  }) async {
    final lease = _sessionFence.capture();
    final effectiveOwner = lease.ownerUserId;

    if (ownerUserId != null && ownerUserId != effectiveOwner) {
      throw StateError('Order owner does not match the active session.');
    }

    final existing = await (_database.select(
      _database.orderRecords,
    )..where((table) => table.id.equals(order.id))).getSingleOrNull();

    lease.ensureCurrent();

    if (existing != null && existing.ownerUserId != effectiveOwner) {
      throw StateError(
        'Refusing to overwrite an order owned by another or unknown account.',
      );
    }

    await _database
        .into(_database.orderRecords)
        .insertOnConflictUpdate(
          OrderRecordsCompanion.insert(
            id: order.id,
            ownerUserId: Value(effectiveOwner),
            status: Value(order.status),
            aggregateStatus: Value(order.aggregateStatus),
            notes: Value(order.notes),
            createdAt: order.createdAt.toUtc(),
            updatedAt: updatedAt,
          ),
        );

    await (_database.delete(
      _database.orderItemRecords,
    )..where((OrderItemRecords table) => table.orderId.equals(order.id))).go();

    for (int index = 0; index < order.items.length; index++) {
      final OrderItemModel item = order.items[index];

      await _database
          .into(_database.orderItemRecords)
          .insert(
            OrderItemRecordsCompanion.insert(
              id: '${order.id}-item-$index',
              orderId: order.id,
              productId: item.productId,
              supplierId: item.supplierId,
              supplierName: Value(item.supplierName),
              productName: item.productName,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              imageUrl: Value(item.imageUrl),
            ),
          );
    }

    lease.ensureCurrent();
  }

  Map<String, Object?> _createOrderPayload(CreateOrderModel request) {
    return <String, Object?>{
      'idempotencyKey': request.idempotencyKey,
      'notes': request.notes,
      'supplierIds': request.supplierIds,
      'items': request.items
          .map(
            (OrderItemModel item) => <String, Object?>{
              'productId': item.productId,
              'productName': item.productName,
              'unitPrice': item.unitPrice,
              'quantity': item.quantity,
              'supplierId': item.supplierId,
              'supplierName': item.supplierName,
              'imageUrl': item.imageUrl,
            },
          )
          .toList(growable: false),
    };
  }

  OrderItemModel _itemRecordToModel(OrderItemRecord row) {
    return OrderItemModel(
      productId: row.productId,
      productName: row.productName,
      unitPrice: row.unitPrice,
      quantity: row.quantity,
      supplierId: row.supplierId,
      supplierName: row.supplierName,
      imageUrl: row.imageUrl,
    );
  }
}

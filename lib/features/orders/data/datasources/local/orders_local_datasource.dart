import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../models/orders_model.dart';
import 'package:uuid/uuid.dart';
import '../orders_datasource.dart';

class OrdersLocalDataSource implements OrdersDataSource {
  OrdersLocalDataSource(this._database);

  final AppDatabase _database;

  @override
  Future<List<OrderModel>> getOrders() async {
    final List<OrderRecord> orderRows =
        await (_database.select(_database.orderRecords)..orderBy([
              (OrderRecords table) => OrderingTerm.desc(table.createdAt),
            ]))
            .get();

    final List<OrderModel> orders = [];

    for (final OrderRecord orderRow in orderRows) {
      final List<OrderItemRecord> itemRows =
          await (_database.select(_database.orderItemRecords)..where(
                (OrderItemRecords table) => table.orderId.equals(orderRow.id),
              ))
              .get();

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

    return List<OrderModel>.unmodifiable(orders);
  }

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
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
      await _saveOrderRows(order, updatedAt: now);

      await _database
          .into(_database.syncOperations)
          .insertOnConflictUpdate(
            SyncOperationsCompanion.insert(
              id: 'order:create:$orderId',
              entityType: 'order',
              entityId: orderId,
              operation: 'create',
              payloadJson: jsonEncode(_createOrderPayload(queuedRequest)),
              createdAt: now,
            ),
          );
    });

    return order;
  }

  /// Persists an order using its existing ID.
  ///
  /// This is used after successful remote creation so the
  /// server-generated order ID is preserved locally.
  Future<OrderModel> saveOrder(OrderModel order) async {
    final DateTime now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await _saveOrderRows(order, updatedAt: now);
    });

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
    final DateTime now = DateTime.now().toUtc();

    await _database.transaction(() async {
      await (_database.delete(_database.orderItemRecords)..where(
            (OrderItemRecords table) => table.orderId.equals(localOrderId),
          ))
          .go();

      await (_database.delete(
        _database.orderRecords,
      )..where((OrderRecords table) => table.id.equals(localOrderId))).go();

      await _saveOrderRows(remoteOrder, updatedAt: now);

      await (_database.delete(
        _database.syncOperations,
      )..where((SyncOperations table) => table.id.equals(operationId))).go();
    });

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
    await _database.transaction(() async {
      await (_database.delete(_database.orderItemRecords)..where(
            (OrderItemRecords table) => table.orderId.equals(localOrderId),
          ))
          .go();

      await (_database.delete(
        _database.orderRecords,
      )..where((OrderRecords table) => table.id.equals(localOrderId))).go();

      await (_database.delete(
        _database.syncOperations,
      )..where((SyncOperations table) => table.id.equals(operationId))).go();
    });
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
    await (_database.update(
      _database.syncOperations,
    )..where((SyncOperations table) => table.id.equals(operationId))).write(
      SyncOperationsCompanion(
        status: const Value(SyncOperationStatuses.retrying),
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: Value(nextAttemptAt.toUtc()),
      ),
    );
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
    await (_database.update(
      _database.syncOperations,
    )..where((SyncOperations table) => table.id.equals(operationId))).write(
      SyncOperationsCompanion(
        status: const Value(SyncOperationStatuses.permanentFailure),
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: const Value<DateTime?>(null),
      ),
    );
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
    final List<OrderModel> snapshot = List<OrderModel>.unmodifiable(
      serverOrders,
    );

    final Set<String> serverOrderIds = snapshot
        .map((OrderModel order) => order.id)
        .toSet();

    final DateTime now = DateTime.now().toUtc();

    await _database.transaction(() async {
      final pendingCreates =
          await (_database.select(_database.syncOperations)..where(
                (SyncOperations table) =>
                    table.entityType.equals('order') &
                    table.operation.equals('create'),
              ))
              .get();

      final Set<String> protectedLocalOrderIds = pendingCreates
          .map((operation) => operation.entityId)
          .toSet();

      final existingOrders = await _database
          .select(_database.orderRecords)
          .get();

      final List<String> staleServerOrderIds = existingOrders
          .map((order) => order.id)
          .where(
            (String orderId) =>
                !serverOrderIds.contains(orderId) &&
                !protectedLocalOrderIds.contains(orderId),
          )
          .toList(growable: false);

      if (staleServerOrderIds.isNotEmpty) {
        await (_database.delete(_database.orderItemRecords)..where(
              (OrderItemRecords table) =>
                  table.orderId.isIn(staleServerOrderIds),
            ))
            .go();

        await (_database.delete(_database.orderRecords)..where(
              (OrderRecords table) => table.id.isIn(staleServerOrderIds),
            ))
            .go();
      }

      for (final OrderModel order in snapshot) {
        await _saveOrderRows(order, updatedAt: now);
      }
    });
  }

  /// Updates only the last known server-authoritative aggregate lifecycle.
  ///
  /// A missing local row is intentionally a no-op: comparison data can still
  /// be viewed even when the order is not present in this local database.
  Future<void> updateAggregateStatusSnapshot({
    required String orderId,
    required String aggregateStatus,
  }) async {
    final DateTime now = DateTime.now().toUtc();

    await (_database.update(
      _database.orderRecords,
    )..where((OrderRecords table) => table.id.equals(orderId))).write(
      OrderRecordsCompanion(
        aggregateStatus: Value(aggregateStatus),
        updatedAt: Value(now),
      ),
    );
  }

  Future<void> _saveOrderRows(
    OrderModel order, {
    required DateTime updatedAt,
  }) async {
    await _database
        .into(_database.orderRecords)
        .insertOnConflictUpdate(
          OrderRecordsCompanion.insert(
            id: order.id,
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

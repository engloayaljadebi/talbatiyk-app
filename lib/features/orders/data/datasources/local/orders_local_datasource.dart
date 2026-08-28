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

  Future<void> markCreateSyncFailure({
    required String operationId,
    required int attempts,
    required Object error,
    required DateTime nextAttemptAt,
  }) async {
    await (_database.update(
      _database.syncOperations,
    )..where((SyncOperations table) => table.id.equals(operationId))).write(
      SyncOperationsCompanion(
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: Value(nextAttemptAt.toUtc()),
      ),
    );
  }

  @override
  Future<OrderModel> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    final OrderRecord? existing =
        await (_database.select(_database.orderRecords)
              ..where((OrderRecords table) => table.id.equals(orderId)))
            .getSingleOrNull();

    if (existing == null) {
      throw StateError('Order not found: $orderId');
    }

    final DateTime now = DateTime.now().toUtc();

    await (_database.update(
      _database.orderRecords,
    )..where((OrderRecords table) => table.id.equals(orderId))).write(
      OrderRecordsCompanion(status: Value(status), updatedAt: Value(now)),
    );

    final List<OrderItemRecord> itemRows = await (_database.select(
      _database.orderItemRecords,
    )..where((OrderItemRecords table) => table.orderId.equals(orderId))).get();

    return OrderModel(
      id: existing.id,
      status: status,
      items: itemRows.map(_itemRecordToModel).toList(growable: false),
      createdAt: existing.createdAt.toUtc(),
      notes: existing.notes,
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

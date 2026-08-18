import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../models/orders_model.dart';
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
          createdAt: orderRow.createdAt,
          notes: orderRow.notes,
        ),
      );
    }

    return List<OrderModel>.unmodifiable(orders);
  }

  @override
  Future<OrderModel> createOrder(CreateOrderModel request) async {
    final DateTime now = DateTime.now().toUtc();
    final String orderId = 'local-order-${now.microsecondsSinceEpoch}';

    await _database.transaction(() async {
      await _database
          .into(_database.orderRecords)
          .insert(
            OrderRecordsCompanion.insert(
              id: orderId,
              status: const Value('pending'),
              notes: Value(request.notes),
              createdAt: now,
              updatedAt: now,
            ),
          );

      for (int index = 0; index < request.items.length; index++) {
        final OrderItemModel item = request.items[index];

        await _database
            .into(_database.orderItemRecords)
            .insert(
              OrderItemRecordsCompanion.insert(
                id: '$orderId-item-$index',
                orderId: orderId,
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
    });

    return OrderModel(
      id: orderId,
      status: 'pending',
      items: request.items,
      createdAt: now,
      notes: request.notes,
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
      createdAt: existing.createdAt,
      notes: existing.notes,
    );
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

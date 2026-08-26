import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../datasources/local/orders_local_datasource.dart';
import '../datasources/orders_datasource.dart';
import '../models/orders_model.dart';

final class OrdersSyncCoordinator {
  OrdersSyncCoordinator({
    required this._database,
    required this._localDataSource,
    required this._remoteDataSource,
  });

  final AppDatabase _database;
  final OrdersLocalDataSource _localDataSource;
  final OrdersDataSource _remoteDataSource;

  bool _isSyncing = false;

  Future<void> syncPendingOrders() async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;

    try {
      final DateTime now = DateTime.now().toUtc();

      final List<SyncOperation> operations =
          await (_database.select(_database.syncOperations)
                ..where(
                  (SyncOperations table) =>
                      table.entityType.equals('order') &
                      table.operation.equals('create') &
                      (table.nextAttemptAt.isNull() |
                          table.nextAttemptAt.isSmallerOrEqualValue(now)),
                )
                ..orderBy([
                  (SyncOperations table) => OrderingTerm.asc(table.createdAt),
                ]))
              .get();

      for (final SyncOperation operation in operations) {
        await _syncCreate(operation);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncCreate(SyncOperation operation) async {
    try {
      final CreateOrderModel request = _decodeCreatePayload(
        operation.payloadJson,
      );

      final OrderModel remoteOrder = await _remoteDataSource.createOrder(
        request,
      );

      await _localDataSource.completeCreateSync(
        localOrderId: operation.entityId,
        operationId: operation.id,
        remoteOrder: remoteOrder,
      );
    } catch (error) {
      final int attempts = operation.attempts + 1;

      await _localDataSource.markCreateSyncFailure(
        operationId: operation.id,
        attempts: attempts,
        error: error,
        nextAttemptAt: DateTime.now().toUtc().add(_retryDelay(attempts)),
      );
    }
  }

  Duration _retryDelay(int attempts) {
    switch (attempts) {
      case 1:
        return const Duration(seconds: 30);
      case 2:
        return const Duration(minutes: 1);
      case 3:
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 15);
    }
  }

  CreateOrderModel _decodeCreatePayload(String payloadJson) {
    final Object? decoded = jsonDecode(payloadJson);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid order Outbox payload.');
    }

    final Object? rawItems = decoded['items'];

    if (rawItems is! List || rawItems.isEmpty) {
      throw const FormatException('Order Outbox payload has no items.');
    }

    return CreateOrderModel(
      notes: decoded['notes'] as String? ?? '',
      items: rawItems
          .map((Object? rawItem) {
            if (rawItem is! Map<String, dynamic>) {
              throw const FormatException('Invalid order Outbox item.');
            }

            return OrderItemModel(
              productId: rawItem['productId'] as String,
              productName: rawItem['productName'] as String,
              unitPrice: (rawItem['unitPrice'] as num).toDouble(),
              quantity: rawItem['quantity'] as int,
              supplierId: rawItem['supplierId'] as String,
              supplierName: rawItem['supplierName'] as String? ?? '',
              imageUrl: rawItem['imageUrl'] as String? ?? '',
            );
          })
          .toList(growable: false),
    );
  }
}

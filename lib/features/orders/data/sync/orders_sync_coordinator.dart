import 'dart:convert';

import 'package:dio/dio.dart';
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
                      (table.status.equals(SyncOperationStatuses.pending) |
                          table.status.equals(SyncOperationStatuses.retrying)) &
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
    final int attempts = operation.attempts + 1;

    late final CreateOrderModel request;

    try {
      // فشل فك الـpayload مشكلة محلية نهائية:
      // إعادة إرسال نفس JSON التالف لاحقًا لن تجعله صالحًا.
      request = _decodeCreatePayload(operation.payloadJson);
    } catch (error) {
      await _localDataSource.markCreateSyncPermanentFailure(
        operationId: operation.id,
        attempts: attempts,
        error: error,
      );

      return;
    }

    try {
      final OrderModel remoteOrder = await _remoteDataSource.createOrder(
        request,
      );

      // إذا فشل reconciliation بعد قبول السيرفر نبقي العملية Retryable.
      // replay بنفس idempotency key يعيد نفس Order بدل إنشاء duplicate.
      await _localDataSource.completeCreateSync(
        localOrderId: operation.entityId,
        operationId: operation.id,
        remoteOrder: remoteOrder,
      );
    } catch (error) {
      if (_isPermanentRemoteFailure(error)) {
        await _localDataSource.markCreateSyncPermanentFailure(
          operationId: operation.id,
          attempts: attempts,
          error: error,
        );

        return;
      }

      // أخطاء الاتصال، 408/429/5xx، والنتائج الغامضة تبقى Retryable.
      // 401 يبقى هنا مؤقتًا إلى أن نعالج Auth/Offline policy في blocker مستقل.
      await _localDataSource.markCreateSyncRetry(
        operationId: operation.id,
        attempts: attempts,
        error: error,
        nextAttemptAt: DateTime.now().toUtc().add(_retryDelay(attempts)),
      );
    }
  }

  bool _isPermanentRemoteFailure(Object error) {
    if (error is! DioException || error.type != DioExceptionType.badResponse) {
      return false;
    }

    final int? statusCode = error.response?.statusCode;

    if (statusCode == null) {
      return false;
    }

    // 401 مرتبط بالـsession وقد ينجح بعد استعادة Authentication.
    // 408 و429 حالات مؤقتة بطبيعتها، لذلك تبقى Retryable.
    return statusCode >= 400 &&
        statusCode < 500 &&
        statusCode != 401 &&
        statusCode != 408 &&
        statusCode != 429;
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

    final Object? rawIdempotencyKey = decoded['idempotencyKey'];

    if (rawIdempotencyKey is! String || rawIdempotencyKey.trim().isEmpty) {
      throw const FormatException(
        'Order Outbox payload has no idempotency key.',
      );
    }

    final Object? rawItems = decoded['items'];

    if (rawItems is! List || rawItems.isEmpty) {
      throw const FormatException('Order Outbox payload has no items.');
    }

    return CreateOrderModel(
      idempotencyKey: rawIdempotencyKey.trim(),
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

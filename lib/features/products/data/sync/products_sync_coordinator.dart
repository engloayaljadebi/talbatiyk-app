import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/products_entity.dart';
import '../datasources/local/products_local_datasource.dart';
import '../datasources/products_datasource.dart';
import '../models/products_model.dart';

/// Replays supplier Product update/delete Outbox mutations.
///
/// Product create publication has its own durable idempotent flow and is not
/// consumed here.
final class ProductsSyncCoordinator {
  ProductsSyncCoordinator({
    required this._localDataSource,
    required this._remoteDataSource,
  });

  final ProductsLocalDataSource _localDataSource;
  final ProductsMutationRemoteDataSource _remoteDataSource;

  bool _isSyncing = false;

  Future<void> syncPendingProducts() async {
    if (_isSyncing) {
      return;
    }

    _isSyncing = true;

    try {
      final database = _localDataSource.database;
      final now = DateTime.now().toUtc();

      final operations =
          await (database.select(database.syncOperations)
                ..where(
                  (table) =>
                      table.entityType.equals('product') &
                      (table.operation.equals('update') |
                          table.operation.equals('delete')) &
                      (table.status.equals(SyncOperationStatuses.pending) |
                          table.status.equals(SyncOperationStatuses.retrying)) &
                      (table.nextAttemptAt.isNull() |
                          table.nextAttemptAt.isSmallerOrEqualValue(now)),
                )
                ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
              .get();

      for (final operation in operations) {
        if (operation.operation == 'update') {
          await _syncUpdate(operation);
        } else if (operation.operation == 'delete') {
          await _syncDelete(operation);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncUpdate(SyncOperation operation) async {
    final attempts = operation.attempts + 1;

    late final Map<String, dynamic> payload;
    late final int expectedVersion;
    late final String imageMutation;
    late final ProductModel product;

    try {
      payload = _decodePayload(operation.payloadJson);
      expectedVersion = _requiredPositiveInt(payload, 'expectedVersion');
      imageMutation = _requiredImageMutation(payload);
      product = _productFromPayload(payload, expectedVersion: expectedVersion);
    } catch (error) {
      await _markPermanentFailure(
        operation: operation,
        attempts: attempts,
        error: error,
      );

      return;
    }

    try {
      final metadataProduct = await _remoteDataSource.updateProductMutation(
        product,
        expectedVersion: expectedVersion,
        removeImage: imageMutation == 'remove',
      );

      ProductModel finalProduct = metadataProduct;

      if (imageMutation == 'replace') {
        final metadataVersion = metadataProduct.serverVersion;

        if (metadataVersion == null || metadataVersion < 1) {
          throw StateError(
            'Server did not return a valid Product version after metadata update.',
          );
        }

        final imagePath = product.localImagePath?.trim();

        if (imagePath == null || imagePath.isEmpty) {
          throw const FormatException(
            'Product replacement image path is missing from Outbox payload.',
          );
        }

        finalProduct = await _remoteDataSource.updateProductImageMutation(
          businessId: product.supplierId,
          productId: product.id,
          expectedVersion: metadataVersion,
          localImagePath: imagePath,
        );
      }

      final finalVersion = finalProduct.serverVersion;

      if (finalVersion == null || finalVersion < 1) {
        throw StateError(
          'Server did not return a valid Product version after mutation.',
        );
      }

      await _localDataSource.upsertSyncedProduct(finalProduct);

      await (_localDataSource.database.delete(
        _localDataSource.database.syncOperations,
      )..where((table) => table.id.equals(operation.id))).go();
    } catch (error) {
      if (_isPermanentRemoteFailure(error)) {
        await _markPermanentFailure(
          operation: operation,
          attempts: attempts,
          error: error,
        );

        return;
      }

      await _markRetry(operation: operation, attempts: attempts, error: error);
    }
  }

  Future<void> _syncDelete(SyncOperation operation) async {
    final attempts = operation.attempts + 1;

    late final Map<String, dynamic> payload;
    late final String businessId;
    late final int expectedVersion;

    try {
      payload = _decodePayload(operation.payloadJson);
      businessId = _requiredString(payload, 'supplierId');
      expectedVersion = _requiredPositiveInt(payload, 'expectedVersion');
    } catch (error) {
      await _markPermanentFailure(
        operation: operation,
        attempts: attempts,
        error: error,
      );

      return;
    }

    try {
      await _remoteDataSource.deleteProductMutation(
        businessId: businessId,
        productId: operation.entityId,
        expectedVersion: expectedVersion,
      );

      final database = _localDataSource.database;

      await database.transaction(() async {
        await (database.delete(
          database.syncOperations,
        )..where((table) => table.id.equals(operation.id))).go();

        await (database.delete(
          database.productRecords,
        )..where((table) => table.id.equals(operation.entityId))).go();
      });
    } catch (error) {
      if (_isPermanentRemoteFailure(error)) {
        await _markPermanentFailure(
          operation: operation,
          attempts: attempts,
          error: error,
        );

        return;
      }

      await _markRetry(operation: operation, attempts: attempts, error: error);
    }
  }

  Future<void> _markRetry({
    required SyncOperation operation,
    required int attempts,
    required Object error,
  }) async {
    final database = _localDataSource.database;

    await database.transaction(() async {
      await (database.update(
        database.syncOperations,
      )..where((table) => table.id.equals(operation.id))).write(
        SyncOperationsCompanion(
          status: const Value(SyncOperationStatuses.retrying),
          attempts: Value(attempts),
          lastError: Value(error.toString()),
          nextAttemptAt: Value(
            DateTime.now().toUtc().add(_retryDelay(attempts)),
          ),
        ),
      );

      await (database.update(
        database.productRecords,
      )..where((table) => table.id.equals(operation.entityId))).write(
        ProductRecordsCompanion(
          syncError: Value(error.toString()),
          syncAttempts: Value(attempts),
        ),
      );
    });
  }

  Future<void> _markPermanentFailure({
    required SyncOperation operation,
    required int attempts,
    required Object error,
  }) async {
    final database = _localDataSource.database;

    await database.transaction(() async {
      await (database.update(
        database.syncOperations,
      )..where((table) => table.id.equals(operation.id))).write(
        SyncOperationsCompanion(
          status: const Value(SyncOperationStatuses.permanentFailure),
          attempts: Value(attempts),
          lastError: Value(error.toString()),
          nextAttemptAt: const Value(null),
        ),
      );

      await (database.update(
        database.productRecords,
      )..where((table) => table.id.equals(operation.entityId))).write(
        ProductRecordsCompanion(
          syncStatus: Value(ProductSyncStatus.failed.name),
          syncError: Value(error.toString()),
          syncAttempts: Value(attempts),
        ),
      );
    });
  }

  bool _isPermanentRemoteFailure(Object error) {
    if (error is! DioException) {
      return error is FormatException ||
          error is ArgumentError ||
          error is StateError;
    }

    final statusCode = error.response?.statusCode;

    if (statusCode == null) {
      return false;
    }

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

  Map<String, dynamic> _decodePayload(String payloadJson) {
    final decoded = jsonDecode(payloadJson);

    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Invalid Product Outbox payload.');
    }

    return decoded;
  }

  ProductModel _productFromPayload(
    Map<String, dynamic> payload, {
    required int expectedVersion,
  }) {
    return ProductModel(
      id: _requiredString(payload, 'id'),
      supplierId: _requiredString(payload, 'supplierId'),
      supplierName: _optionalString(payload, 'supplierName'),
      supplierGovernorate: _nullableString(payload, 'supplierGovernorate'),
      name: _requiredString(payload, 'name'),
      price: _requiredNumber(payload, 'price').toDouble(),
      imageUrl: _optionalString(payload, 'imageUrl'),
      localImagePath: _nullableString(payload, 'localImagePath'),
      serverVersion: expectedVersion,
      category: _optionalString(payload, 'category'),
      brand: _optionalString(payload, 'brand'),
      isAvailable: _requiredBool(payload, 'isAvailable'),
      description: _optionalString(payload, 'description'),
      colors: _stringList(payload['colors']),
      quantity: _requiredInt(payload, 'quantity'),
      discount: _optionalNumber(payload, 'discount').toDouble(),
      rating: _optionalNumber(payload, 'rating').toDouble(),
      syncStatus: ProductSyncStatus.pendingUpdate,
      syncError: null,
      createdAt: _optionalDateTime(payload['createdAt']),
      updatedAt: _optionalDateTime(payload['updatedAt']),
    );
  }

  String _requiredImageMutation(Map<String, dynamic> payload) {
    final value = payload['imageMutation'];

    if (value == 'keep' || value == 'replace' || value == 'remove') {
      return value as String;
    }

    throw const FormatException(
      'Invalid Product image mutation in Outbox payload.',
    );
  }

  String _requiredString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    throw FormatException('Product Outbox field "$key" is required.');
  }

  String _optionalString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    return value is String ? value : '';
  }

  String? _nullableString(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value == null) {
      return null;
    }

    if (value is String) {
      final normalized = value.trim();

      return normalized.isEmpty ? null : normalized;
    }

    throw FormatException('Product Outbox field "$key" must be a string.');
  }

  num _requiredNumber(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is num) {
      return value;
    }

    throw FormatException('Product Outbox field "$key" must be numeric.');
  }

  num _optionalNumber(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    return value is num ? value : 0;
  }

  int _requiredInt(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is int) {
      return value;
    }

    if (value is num && value == value.roundToDouble()) {
      return value.toInt();
    }

    throw FormatException('Product Outbox field "$key" must be an integer.');
  }

  int _requiredPositiveInt(Map<String, dynamic> payload, String key) {
    final value = _requiredInt(payload, key);

    if (value < 1) {
      throw FormatException('Product Outbox field "$key" must be positive.');
    }

    return value;
  }

  bool _requiredBool(Map<String, dynamic> payload, String key) {
    final value = payload[key];

    if (value is bool) {
      return value;
    }

    throw FormatException('Product Outbox field "$key" must be boolean.');
  }

  List<String> _stringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }

    return List<String>.unmodifiable(value.whereType<String>());
  }

  DateTime? _optionalDateTime(Object? value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value)?.toUtc();
  }
}

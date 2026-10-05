import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_local_datasource.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/data/sync/products_sync_coordinator.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  late AppDatabase database;
  late ProductsLocalDataSource local;
  late _FakeMutationRemoteDataSource remote;
  late ProductsSyncCoordinator coordinator;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    local = ProductsLocalDataSource(database);
    remote = _FakeMutationRemoteDataSource();
    coordinator = ProductsSyncCoordinator(
      localDataSource: local,
      remoteDataSource: remote,
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'replacement update preserves expected version and chains image version',
    () async {
      await _seedProduct(
        local,
        id: 'replace-product',
        version: 7,
        imageUrl: 'https://server.test/old.jpg',
      );

      await local.updateProduct(
        _editedProduct(
          id: 'replace-product',
          imageUrl: '',
          localImagePath: '/local/replacement.jpg',
        ),
      );

      final queued =
          await (database.select(database.syncOperations)..where(
                (row) => row.id.equals('product:update:replace-product'),
              ))
              .getSingle();

      final payload = jsonDecode(queued.payloadJson) as Map<String, dynamic>;

      expect(payload['expectedVersion'], 7);
      expect(payload['imageMutation'], 'replace');

      await coordinator.syncPendingProducts();

      expect(remote.metadataExpectedVersions, <int>[7]);
      expect(remote.imageExpectedVersions, <int>[8]);

      final record = await (database.select(
        database.productRecords,
      )..where((row) => row.id.equals('replace-product'))).getSingle();

      expect(record.serverVersion, 9);
      expect(record.syncStatus, ProductSyncStatus.synced.name);
      expect(record.localImagePath, null);
      expect(record.remoteImageUrl, 'https://server.test/new.jpg');

      final remaining = await (database.select(
        database.syncOperations,
      )..where((row) => row.entityId.equals('replace-product'))).get();

      expect(remaining, isEmpty);
    },
  );

  test('repeated offline edit preserves durable remove image intent', () async {
    await _seedProduct(
      local,
      id: 'remove-product',
      version: 8,
      imageUrl: 'https://server.test/old.jpg',
    );

    await local.updateProduct(
      _editedProduct(id: 'remove-product', imageUrl: '', localImagePath: null),
    );

    await local.updateProduct(
      _editedProduct(
        id: 'remove-product',
        imageUrl: '',
        localImagePath: null,
        name: 'Second edit',
      ),
    );

    final queued =
        await (database.select(database.syncOperations)
              ..where((row) => row.id.equals('product:update:remove-product')))
            .getSingle();

    final payload = jsonDecode(queued.payloadJson) as Map<String, dynamic>;

    expect(payload['expectedVersion'], 8);
    expect(payload['imageMutation'], 'remove');

    await coordinator.syncPendingProducts();

    expect(remote.lastRemoveImage, isTrue);

    final record = await (database.select(
      database.productRecords,
    )..where((row) => row.id.equals('remove-product'))).getSingle();

    expect(record.serverVersion, 9);
    expect(record.remoteImageUrl, null);
    expect(record.syncStatus, ProductSyncStatus.synced.name);
  });

  test('HTTP 409 becomes permanent conflict instead of retry loop', () async {
    await _seedProduct(
      local,
      id: 'conflict-product',
      version: 4,
      imageUrl: 'https://server.test/old.jpg',
    );

    await local.updateProduct(
      _editedProduct(
        id: 'conflict-product',
        imageUrl: 'https://server.test/old.jpg',
      ),
    );

    remote.failureStatus = 409;

    await coordinator.syncPendingProducts();

    final operation =
        await (database.select(
              database.syncOperations,
            )..where((row) => row.id.equals('product:update:conflict-product')))
            .getSingle();

    final product = await (database.select(
      database.productRecords,
    )..where((row) => row.id.equals('conflict-product'))).getSingle();

    expect(operation.status, SyncOperationStatuses.permanentFailure);
    expect(operation.attempts, 1);
    expect(operation.nextAttemptAt, null);
    expect(product.syncStatus, ProductSyncStatus.failed.name);
  });

  test('HTTP 503 stays retryable with backoff', () async {
    await _seedProduct(
      local,
      id: 'retry-product',
      version: 5,
      imageUrl: 'https://server.test/old.jpg',
    );

    await local.updateProduct(
      _editedProduct(
        id: 'retry-product',
        imageUrl: 'https://server.test/old.jpg',
      ),
    );

    remote.failureStatus = 503;

    await coordinator.syncPendingProducts();

    final operation =
        await (database.select(database.syncOperations)
              ..where((row) => row.id.equals('product:update:retry-product')))
            .getSingle();

    expect(operation.status, SyncOperationStatuses.retrying);
    expect(operation.attempts, 1);
    expect(operation.nextAttemptAt, isNot(null));
  });

  test(
    'delete uses last confirmed server version and removes local tombstone on success',
    () async {
      await _seedProduct(
        local,
        id: 'delete-product',
        version: 11,
        imageUrl: 'https://server.test/old.jpg',
      );

      await local.deleteProduct('delete-product');

      final queued =
          await (database.select(
                database.syncOperations,
              )..where((row) => row.id.equals('product:delete:delete-product')))
              .getSingle();

      final payload = jsonDecode(queued.payloadJson) as Map<String, dynamic>;

      expect(payload['expectedVersion'], 11);

      await coordinator.syncPendingProducts();

      expect(remote.deleteExpectedVersions, <int>[11]);

      final record = await (database.select(
        database.productRecords,
      )..where((row) => row.id.equals('delete-product'))).getSingleOrNull();

      final operation =
          await (database.select(
                database.syncOperations,
              )..where((row) => row.id.equals('product:delete:delete-product')))
              .getSingleOrNull();

      expect(record, null);
      expect(operation, null);
    },
  );
}

Future<void> _seedProduct(
  ProductsLocalDataSource local, {
  required String id,
  required int version,
  required String imageUrl,
}) {
  return local.upsertSyncedProduct(
    ProductModel(
      id: id,
      supplierId: 'supplier-1',
      supplierName: 'Supplier One',
      name: 'Server Product',
      price: 100,
      imageUrl: imageUrl,
      serverVersion: version,
      category: 'Tests',
      brand: 'Talbatiyk',
      isAvailable: true,
      description: 'Server product',
      quantity: 5,
      createdAt: DateTime.utc(2026, 10, 4),
      updatedAt: DateTime.utc(2026, 10, 4),
    ),
  );
}

ProductModel _editedProduct({
  required String id,
  required String imageUrl,
  String? localImagePath,
  String name = 'Edited Product',
}) {
  return ProductModel(
    id: id,
    supplierId: 'supplier-1',
    supplierName: 'Supplier One',
    name: name,
    price: 125,
    imageUrl: imageUrl,
    localImagePath: localImagePath,
    category: 'Tests',
    brand: 'Talbatiyk',
    isAvailable: true,
    description: 'Edited product',
    quantity: 10,
  );
}

final class _FakeMutationRemoteDataSource
    implements ProductsMutationRemoteDataSource {
  int? failureStatus;

  final List<int> metadataExpectedVersions = <int>[];
  final List<int> imageExpectedVersions = <int>[];
  final List<int> deleteExpectedVersions = <int>[];

  bool? lastRemoveImage;
  ProductModel? _lastMetadataProduct;

  @override
  Future<ProductModel> updateProductMutation(
    ProductModel product, {
    required int expectedVersion,
    required bool removeImage,
  }) async {
    _throwIfConfigured();

    metadataExpectedVersions.add(expectedVersion);
    lastRemoveImage = removeImage;

    final result = _serverProduct(
      product,
      version: expectedVersion + 1,
      imageUrl: removeImage
          ? ''
          : (product.imageUrl.trim().isEmpty
                ? 'https://server.test/old.jpg'
                : product.imageUrl),
    );

    _lastMetadataProduct = result;

    return result;
  }

  @override
  Future<ProductModel> updateProductImageMutation({
    required String businessId,
    required String productId,
    required int expectedVersion,
    required String localImagePath,
  }) async {
    _throwIfConfigured();

    imageExpectedVersions.add(expectedVersion);

    final source = _lastMetadataProduct;

    if (source == null) {
      throw StateError('Metadata update was not called first.');
    }

    return _serverProduct(
      source,
      version: expectedVersion + 1,
      imageUrl: 'https://server.test/new.jpg',
    );
  }

  @override
  Future<void> deleteProductMutation({
    required String businessId,
    required String productId,
    required int expectedVersion,
  }) async {
    _throwIfConfigured();

    deleteExpectedVersions.add(expectedVersion);
  }

  void _throwIfConfigured() {
    final status = failureStatus;

    if (status == null) {
      return;
    }

    final request = RequestOptions(path: '/products');

    throw DioException(
      requestOptions: request,
      response: Response<void>(requestOptions: request, statusCode: status),
      type: DioExceptionType.badResponse,
    );
  }

  ProductModel _serverProduct(
    ProductModel source, {
    required int version,
    required String imageUrl,
  }) {
    return ProductModel(
      id: source.id,
      supplierId: source.supplierId,
      supplierName: source.supplierName,
      supplierGovernorate: source.supplierGovernorate,
      name: source.name,
      price: source.price,
      imageUrl: imageUrl,
      serverVersion: version,
      category: source.category,
      brand: source.brand,
      isAvailable: source.isAvailable,
      description: source.description,
      colors: source.colors,
      quantity: source.quantity,
      discount: source.discount,
      rating: source.rating,
      syncStatus: ProductSyncStatus.synced,
      createdAt: source.createdAt ?? DateTime.utc(2026, 10, 4),
      updatedAt: DateTime.utc(2026, 10, 4, 1),
    );
  }
}

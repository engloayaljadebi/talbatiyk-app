import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/products_entity.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// Drift-backed source for supplier product management.
///
/// Reads use ProductRecords, while business writes may create Outbox work.
class ProductsLocalDataSource
    implements
        ProductsDataSource,
        ProductsWritableDataSource,
        ProductsSyncedStoreDataSource,
        ProductsPublishAttemptDataSource {
  ProductsLocalDataSource(this.database);

  final AppDatabase database;

  @override
  Future<List<ProductModel>> getProducts() async {
    /// نستبعد المنتجات المحذوفة محليًا ونرتب الأحدث أولًا.
    final query = database.select(database.productRecords)
      ..where((table) => table.deletedAt.isNull())
      ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]);

    final records = await query.get();

    return List<ProductModel>.unmodifiable(
      records.map((record) {
        return ProductModel(
          id: record.id,
          supplierId: record.supplierId,
          supplierName: record.supplierName,
          name: record.name,
          price: record.price,
          imageUrl: record.remoteImageUrl ?? '',
          localImagePath: record.localImagePath,
          serverVersion: record.serverVersion,
          category: record.category,
          brand: record.brand,
          isAvailable: record.isAvailable,
          description: record.description,
          colors: _decodeColors(record.colorsJson),
          quantity: record.quantity,
          discount: record.discount,
          rating: record.rating,
          syncStatus: _decodeSyncStatus(record.syncStatus),
          syncError: record.syncError,
          createdAt: record.createdAt,
          updatedAt: record.updatedAt,
        );
      }),
    );
  }

  /// Reconciles the complete server list for one managed Business.
  ///
  /// Local pending updates/deletes are never overwritten by an older server
  /// snapshot. Clean local rows absent from the complete server list are stale.
  Future<List<ProductModel>> reconcileBusinessProducts({
    required String businessId,
    required List<ProductModel> serverProducts,
  }) async {
    final normalizedBusinessId = businessId.trim();

    if (normalizedBusinessId.isEmpty) {
      throw ArgumentError(
        'Business ID is required to reconcile managed Products.',
      );
    }

    final serverIds = <String>{};

    for (final product in serverProducts) {
      final productId = product.id.trim();

      if (productId.isEmpty) {
        throw StateError(
          'Supplier management response contains an empty Product ID.',
        );
      }

      if (product.supplierId.trim() != normalizedBusinessId) {
        throw StateError(
          'Supplier management response contains a Product '
          'outside the requested Business.',
        );
      }

      final version = product.serverVersion;

      if (version == null || version < 1) {
        throw StateError(
          'Supplier management Product does not have '
          'a valid server version.',
        );
      }

      if (!serverIds.add(productId)) {
        throw StateError(
          'Supplier management response contains duplicate Product IDs.',
        );
      }
    }

    return database.transaction(() async {
      final existingRecords = await (database.select(
        database.productRecords,
      )..where((table) => table.supplierId.equals(normalizedBusinessId))).get();

      final existingById = {
        for (final record in existingRecords) record.id: record,
      };

      final visible = <ProductModel>[];

      for (final serverProduct in serverProducts) {
        final current = existingById[serverProduct.id];

        if (current != null) {
          final currentStatus = _decodeSyncStatus(current.syncStatus);

          if (current.deletedAt != null ||
              currentStatus == ProductSyncStatus.pendingDelete) {
            continue;
          }

          if (currentStatus != ProductSyncStatus.synced) {
            visible.add(
              ProductModel(
                id: current.id,
                supplierId: current.supplierId,
                supplierName: current.supplierName,
                name: current.name,
                price: current.price,
                imageUrl: current.remoteImageUrl ?? '',
                localImagePath: current.localImagePath,
                serverVersion: current.serverVersion,
                category: current.category,
                brand: current.brand,
                isAvailable: current.isAvailable,
                description: current.description,
                colors: _decodeColors(current.colorsJson),
                quantity: current.quantity,
                discount: current.discount,
                rating: current.rating,
                syncStatus: currentStatus,
                syncError: current.syncError,
                createdAt: current.createdAt,
                updatedAt: current.updatedAt,
              ),
            );

            continue;
          }
        }

        final synced = await upsertSyncedProduct(serverProduct);

        visible.add(synced);
      }

      for (final current in existingRecords) {
        if (serverIds.contains(current.id)) {
          continue;
        }

        final currentStatus = _decodeSyncStatus(current.syncStatus);

        if (current.deletedAt != null ||
            currentStatus == ProductSyncStatus.pendingDelete) {
          continue;
        }

        if (currentStatus != ProductSyncStatus.synced) {
          visible.add(
            ProductModel(
              id: current.id,
              supplierId: current.supplierId,
              supplierName: current.supplierName,
              name: current.name,
              price: current.price,
              imageUrl: current.remoteImageUrl ?? '',
              localImagePath: current.localImagePath,
              serverVersion: current.serverVersion,
              category: current.category,
              brand: current.brand,
              isAvailable: current.isAvailable,
              description: current.description,
              colors: _decodeColors(current.colorsJson),
              quantity: current.quantity,
              discount: current.discount,
              rating: current.rating,
              syncStatus: currentStatus,
              syncError: current.syncError,
              createdAt: current.createdAt,
              updatedAt: current.updatedAt,
            ),
          );

          continue;
        }

        await (database.delete(
          database.productRecords,
        )..where((table) => table.id.equals(current.id))).go();
      }

      return List<ProductModel>.unmodifiable(visible);
    });
  }

  /// يحفظ المنتج محليًا ويسجل عملية رفعه للسحابة في نفس المعاملة.
  ///
  /// استخدام transaction يضمن عدم حفظ المنتج دون تسجيل المزامنة،
  /// أو تسجيل المزامنة دون حفظ المنتج.
  @override
  Future<ProductModel> createProduct(ProductModel product) async {
    final now = DateTime.now();

    /// أي منتج جديد يُحفظ أولًا بحالة انتظار الرفع.
    final pendingProduct = ProductModel(
      id: product.id,
      supplierId: product.supplierId,
      supplierName: product.supplierName,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
      localImagePath: product.localImagePath,
      category: product.category,
      brand: product.brand,
      isAvailable: product.isAvailable,
      description: product.description,
      colors: product.colors,
      quantity: product.quantity,
      discount: product.discount,
      rating: product.rating,
      syncStatus: ProductSyncStatus.pendingCreate,
      createdAt: product.createdAt ?? now,
      updatedAt: now,
    );

    await database.transaction(() async {
      /// نحفظ المنتج أو نحدّث السجل إذا كان المعرف موجودًا مسبقًا.
      await database
          .into(database.productRecords)
          .insertOnConflictUpdate(
            ProductRecordsCompanion.insert(
              id: pendingProduct.id,
              supplierId: pendingProduct.supplierId,
              supplierName: pendingProduct.supplierName,
              name: pendingProduct.name,
              price: pendingProduct.price,
              category: Value(pendingProduct.category),
              brand: Value(pendingProduct.brand),
              description: Value(pendingProduct.description),
              colorsJson: Value(jsonEncode(pendingProduct.colors)),
              quantity: Value(pendingProduct.quantity),
              isAvailable: Value(pendingProduct.isAvailable),
              discount: Value(pendingProduct.discount),
              rating: Value(pendingProduct.rating),
              localImagePath: Value(pendingProduct.localImagePath),
              remoteImageUrl: Value(
                pendingProduct.imageUrl.trim().isEmpty
                    ? null
                    : pendingProduct.imageUrl,
              ),
              syncStatus: Value(pendingProduct.syncStatus.name),
              syncError: Value(pendingProduct.syncError),
              createdAt: pendingProduct.createdAt!,
              updatedAt: pendingProduct.updatedAt!,
            ),
          );

      /// نسجل عملية إنشاء في طابور المزامنة ليتم تنفيذها عند توفر الإنترنت.
      await database
          .into(database.syncOperations)
          .insertOnConflictUpdate(
            SyncOperationsCompanion.insert(
              id: 'product:create:${pendingProduct.id}',
              entityType: 'product',
              entityId: pendingProduct.id,
              operation: 'create',
              payloadJson: jsonEncode(pendingProduct.toJson()),
              createdAt: now,
            ),
          );
    });

    return pendingProduct;
  }

  /// يحفظ النسخة الرسمية التي أعادها Laravel بعد نجاح النشر.
  ///
  /// لا ننشئ Outbox هنا لأن المنتج موجود بالفعل على الخادم.
  /// الهدف هو جعل قائمة إدارة منتجات المورد مطابقة للحقيقة السحابية مباشرة.
  @override
  Future<ProductModel> upsertSyncedProduct(ProductModel product) async {
    final now = DateTime.now();

    final syncedProduct = ProductModel(
      id: product.id,
      supplierId: product.supplierId,
      supplierName: product.supplierName,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
      localImagePath: product.localImagePath,
      serverVersion: product.serverVersion,
      category: product.category,
      brand: product.brand,
      isAvailable: product.isAvailable,
      description: product.description,
      colors: product.colors,
      quantity: product.quantity,
      discount: product.discount,
      rating: product.rating,
      syncStatus: ProductSyncStatus.synced,
      syncError: null,
      createdAt: product.createdAt ?? now,
      updatedAt: product.updatedAt ?? now,
    );

    await database
        .into(database.productRecords)
        .insertOnConflictUpdate(
          ProductRecordsCompanion.insert(
            id: syncedProduct.id,
            supplierId: syncedProduct.supplierId,
            supplierName: syncedProduct.supplierName,
            name: syncedProduct.name,
            price: syncedProduct.price,
            category: Value(syncedProduct.category),
            brand: Value(syncedProduct.brand),
            description: Value(syncedProduct.description),
            colorsJson: Value(jsonEncode(syncedProduct.colors)),
            quantity: Value(syncedProduct.quantity),
            isAvailable: Value(syncedProduct.isAvailable),
            discount: Value(syncedProduct.discount),
            rating: Value(syncedProduct.rating),
            localImagePath: Value(syncedProduct.localImagePath),
            serverVersion: Value(syncedProduct.serverVersion),
            remoteImageUrl: Value(
              syncedProduct.imageUrl.trim().isEmpty
                  ? null
                  : syncedProduct.imageUrl,
            ),
            syncStatus: Value(ProductSyncStatus.synced.name),
            syncError: const Value(null),
            createdAt: syncedProduct.createdAt!,
            updatedAt: syncedProduct.updatedAt!,
          ),
        );

    return syncedProduct;
  }

  @override
  Future<ProductPublishAttempt> preparePublishAttempt({
    required ProductModel product,
    required String idempotencyKey,
  }) async {
    final normalizedKey = idempotencyKey.trim();
    final clientProductId = product.id.trim();

    if (normalizedKey.isEmpty) {
      throw ArgumentError('مفتاح Idempotency مطلوب لنشر المنتج.');
    }

    if (clientProductId.isEmpty) {
      throw ArgumentError('معرف محاولة نشر المنتج مطلوب.');
    }

    return database.transaction(() async {
      final existing =
          await (database.select(database.productPublishAttemptRecords)..where(
                (table) => table.clientProductId.equals(clientProductId),
              ))
              .getSingleOrNull();

      if (existing != null) {
        if (!_publishAttemptMatchesProduct(existing, product)) {
          throw StateError(
            'محاولة نشر المنتج الحالية مرتبطة ببيانات مختلفة. '
            'يجب بدء عملية نشر منطقية جديدة بدل تغيير payload لنفس المحاولة.',
          );
        }

        return _mapPublishAttempt(existing);
      }

      final now = DateTime.now().toUtc();

      await database
          .into(database.productPublishAttemptRecords)
          .insert(
            ProductPublishAttemptRecordsCompanion.insert(
              idempotencyKey: normalizedKey,
              clientProductId: clientProductId,
              supplierId: product.supplierId.trim(),
              supplierName: product.supplierName.trim(),
              name: product.name.trim(),
              category: product.category.trim(),
              brand: Value(product.brand.trim()),
              description: Value(product.description.trim()),
              price: product.price,
              quantity: product.quantity,
              isAvailable: product.isAvailable,
              localImagePath: Value(
                _normalizedImagePath(product.localImagePath),
              ),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final inserted =
          await (database.select(database.productPublishAttemptRecords)
                ..where((table) => table.idempotencyKey.equals(normalizedKey)))
              .getSingle();

      return _mapPublishAttempt(inserted);
    });
  }

  @override
  Future<List<ProductPublishAttempt>> getRetryablePublishAttempts() async {
    final now = DateTime.now().toUtc();

    final rows =
        await (database.select(database.productPublishAttemptRecords)
              ..where(
                (table) =>
                    (table.status.equals(
                          ProductPublishAttemptStatuses.pending,
                        ) |
                        table.status.equals(
                          ProductPublishAttemptStatuses.retrying,
                        )) &
                    (table.nextAttemptAt.isNull() |
                        table.nextAttemptAt.isSmallerOrEqualValue(now)),
              )
              ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
            .get();

    return List<ProductPublishAttempt>.unmodifiable(
      rows.map(_mapPublishAttempt),
    );
  }

  @override
  Future<void> markPublishAttemptRetry({
    required String idempotencyKey,
    required int attempts,
    required Object error,
    required DateTime nextAttemptAt,
  }) async {
    await (database.update(
      database.productPublishAttemptRecords,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).write(
      ProductPublishAttemptRecordsCompanion(
        status: const Value(ProductPublishAttemptStatuses.retrying),
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: Value(nextAttemptAt.toUtc()),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> markPublishAttemptPermanentFailure({
    required String idempotencyKey,
    required int attempts,
    required Object error,
  }) async {
    await (database.update(
      database.productPublishAttemptRecords,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).write(
      ProductPublishAttemptRecordsCompanion(
        status: const Value(ProductPublishAttemptStatuses.permanentFailure),
        attempts: Value(attempts),
        lastError: Value(error.toString()),
        nextAttemptAt: const Value<DateTime?>(null),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  @override
  Future<void> completePublishAttempt(String idempotencyKey) async {
    await (database.delete(
      database.productPublishAttemptRecords,
    )..where((table) => table.idempotencyKey.equals(idempotencyKey))).go();
  }

  ProductPublishAttempt _mapPublishAttempt(ProductPublishAttemptRecord record) {
    return ProductPublishAttempt(
      idempotencyKey: record.idempotencyKey,
      status: _decodePublishAttemptStatus(record.status),
      attempts: record.attempts,
      lastError: record.lastError,
      nextAttemptAt: record.nextAttemptAt?.toUtc(),
      product: ProductModel(
        id: record.clientProductId,
        supplierId: record.supplierId,
        supplierName: record.supplierName,
        name: record.name,
        price: record.price,
        imageUrl: '',
        localImagePath: record.localImagePath,
        category: record.category,
        brand: record.brand,
        isAvailable: record.isAvailable,
        description: record.description,
        quantity: record.quantity,
      ),
    );
  }

  bool _publishAttemptMatchesProduct(
    ProductPublishAttemptRecord record,
    ProductModel product,
  ) {
    return record.clientProductId == product.id.trim() &&
        record.supplierId == product.supplierId.trim() &&
        record.supplierName == product.supplierName.trim() &&
        record.name == product.name.trim() &&
        record.category == product.category.trim() &&
        record.brand == product.brand.trim() &&
        record.description == product.description.trim() &&
        record.price == product.price &&
        record.quantity == product.quantity &&
        record.isAvailable == product.isAvailable &&
        record.localImagePath == _normalizedImagePath(product.localImagePath);
  }

  String? _normalizedImagePath(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }

  ProductPublishAttemptStatus _decodePublishAttemptStatus(String status) {
    switch (status) {
      case ProductPublishAttemptStatuses.pending:
        return ProductPublishAttemptStatus.pending;

      case ProductPublishAttemptStatuses.retrying:
        return ProductPublishAttemptStatus.retrying;

      case ProductPublishAttemptStatuses.permanentFailure:
        return ProductPublishAttemptStatus.permanentFailure;

      default:
        throw StateError('حالة محاولة نشر المنتج غير معروفة: $status');
    }
  }

  /// يحدّث المنتج محليًا ويسجل العملية المناسبة في طابور المزامنة.
  @override
  Future<ProductModel> updateProduct(ProductModel product) async {
    final now = DateTime.now().toUtc();

    final currentRecord = await (database.select(
      database.productRecords,
    )..where((table) => table.id.equals(product.id))).getSingleOrNull();

    if (currentRecord == null) {
      throw StateError('Cannot update a Product that is not stored locally.');
    }

    final createOperationId = 'product:create:${product.id}';

    final pendingCreateOperation = await (database.select(
      database.syncOperations,
    )..where((table) => table.id.equals(createOperationId))).getSingleOrNull();

    final isWaitingForCreate = pendingCreateOperation != null;

    final updateOperationId = 'product:update:${product.id}';

    final existingUpdateOperation = await (database.select(
      database.syncOperations,
    )..where((table) => table.id.equals(updateOperationId))).getSingleOrNull();

    if (!isWaitingForCreate && currentRecord.serverVersion == null) {
      throw StateError(
        'Cannot queue a server Product update without a confirmed server version.',
      );
    }

    final imageMutation = isWaitingForCreate
        ? 'keep'
        : _resolveImageMutation(
            localImagePath: product.localImagePath,
            imageUrl: product.imageUrl,
            currentRemoteImageUrl: currentRecord.remoteImageUrl,
            previousPayloadJson: existingUpdateOperation?.payloadJson,
          );

    final nextSyncStatus = isWaitingForCreate
        ? ProductSyncStatus.pendingCreate
        : ProductSyncStatus.pendingUpdate;

    final updatedProduct = ProductModel(
      id: product.id,
      supplierId: product.supplierId,
      supplierName: product.supplierName,
      supplierGovernorate: product.supplierGovernorate,
      name: product.name,
      price: product.price,
      imageUrl: product.imageUrl,
      localImagePath: product.localImagePath,
      serverVersion: currentRecord.serverVersion,
      category: product.category,
      brand: product.brand,
      isAvailable: product.isAvailable,
      description: product.description,
      colors: product.colors,
      quantity: product.quantity,
      discount: product.discount,
      rating: product.rating,
      syncStatus: nextSyncStatus,
      syncError: null,
      createdAt: currentRecord.createdAt,
      updatedAt: now,
    );

    await database.transaction(() async {
      await (database.update(
        database.productRecords,
      )..where((table) => table.id.equals(product.id))).write(
        ProductRecordsCompanion(
          supplierId: Value(updatedProduct.supplierId),
          supplierName: Value(updatedProduct.supplierName),
          name: Value(updatedProduct.name),
          category: Value(updatedProduct.category),
          brand: Value(updatedProduct.brand),
          description: Value(updatedProduct.description),
          price: Value(updatedProduct.price),
          quantity: Value(updatedProduct.quantity),
          isAvailable: Value(updatedProduct.isAvailable),
          discount: Value(updatedProduct.discount),
          rating: Value(updatedProduct.rating),
          colorsJson: Value(jsonEncode(updatedProduct.colors)),
          localImagePath: Value(updatedProduct.localImagePath),
          remoteImageUrl: Value(
            updatedProduct.imageUrl.trim().isEmpty
                ? null
                : updatedProduct.imageUrl,
          ),
          serverVersion: Value(currentRecord.serverVersion),
          syncStatus: Value(nextSyncStatus.name),
          syncError: const Value(null),
          syncAttempts: const Value(0),
          updatedAt: Value(now),
          deletedAt: const Value(null),
        ),
      );

      if (isWaitingForCreate) {
        await (database.delete(
          database.syncOperations,
        )..where((table) => table.id.equals(updateOperationId))).go();

        await (database.update(
          database.syncOperations,
        )..where((table) => table.id.equals(createOperationId))).write(
          SyncOperationsCompanion(
            payloadJson: Value(jsonEncode(updatedProduct.toJson())),
            status: const Value(SyncOperationStatuses.pending),
            attempts: const Value(0),
            lastError: const Value(null),
            nextAttemptAt: const Value(null),
          ),
        );

        return;
      }

      await (database.delete(
        database.syncOperations,
      )..where((table) => table.id.equals(updateOperationId))).go();

      await database
          .into(database.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              id: updateOperationId,
              entityType: 'product',
              entityId: product.id,
              operation: 'update',
              payloadJson: jsonEncode(<String, dynamic>{
                ...updatedProduct.toJson(),
                'expectedVersion': currentRecord.serverVersion,
                'imageMutation': imageMutation,
              }),
              createdAt: now,
            ),
          );
    });

    return updatedProduct;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    final normalizedProductId = productId.trim();

    if (normalizedProductId.isEmpty) {
      throw ArgumentError('Product ID is required.');
    }

    final currentRecord =
        await (database.select(database.productRecords)
              ..where((table) => table.id.equals(normalizedProductId)))
            .getSingleOrNull();

    if (currentRecord == null) {
      return;
    }

    final createOperationId = 'product:create:$normalizedProductId';

    final pendingCreateOperation = await (database.select(
      database.syncOperations,
    )..where((table) => table.id.equals(createOperationId))).getSingleOrNull();

    if (pendingCreateOperation == null && currentRecord.serverVersion == null) {
      throw StateError(
        'Cannot queue a server Product delete without a confirmed server version.',
      );
    }

    final now = DateTime.now().toUtc();

    await database.transaction(() async {
      if (pendingCreateOperation != null) {
        await (database.delete(
          database.syncOperations,
        )..where((table) => table.entityId.equals(normalizedProductId))).go();

        await (database.delete(
          database.productRecords,
        )..where((table) => table.id.equals(normalizedProductId))).go();

        return;
      }

      await (database.update(
        database.productRecords,
      )..where((table) => table.id.equals(normalizedProductId))).write(
        ProductRecordsCompanion(
          syncStatus: Value(ProductSyncStatus.pendingDelete.name),
          syncError: const Value(null),
          syncAttempts: const Value(0),
          updatedAt: Value(now),
          deletedAt: Value(now),
        ),
      );

      await (database.delete(database.syncOperations)..where(
            (table) => table.id.equals('product:update:$normalizedProductId'),
          ))
          .go();

      await (database.delete(database.syncOperations)..where(
            (table) => table.id.equals('product:delete:$normalizedProductId'),
          ))
          .go();

      await database
          .into(database.syncOperations)
          .insert(
            SyncOperationsCompanion.insert(
              id: 'product:delete:$normalizedProductId',
              entityType: 'product',
              entityId: normalizedProductId,
              operation: 'delete',
              payloadJson: jsonEncode(<String, dynamic>{
                'id': normalizedProductId,
                'supplierId': currentRecord.supplierId,
                'expectedVersion': currentRecord.serverVersion,
                'deletedAt': now.toIso8601String(),
              }),
              createdAt: now,
            ),
          );
    });
  }

  String _resolveImageMutation({
    required String? localImagePath,
    required String imageUrl,
    required String? currentRemoteImageUrl,
    required String? previousPayloadJson,
  }) {
    final normalizedLocalPath = localImagePath?.trim();

    if (normalizedLocalPath != null && normalizedLocalPath.isNotEmpty) {
      return 'replace';
    }

    final normalizedImageUrl = imageUrl.trim();
    final currentRemote = currentRemoteImageUrl?.trim();

    if (normalizedImageUrl.isEmpty &&
        currentRemote != null &&
        currentRemote.isNotEmpty) {
      return 'remove';
    }

    if (normalizedImageUrl.isEmpty &&
        (currentRemote == null || currentRemote.isEmpty) &&
        previousPayloadJson != null) {
      try {
        final decoded = jsonDecode(previousPayloadJson);

        if (decoded is Map<String, dynamic> &&
            decoded['imageMutation'] == 'remove') {
          return 'remove';
        }
      } catch (_) {
        // Invalid historical payload is handled by ProductsSyncCoordinator.
      }
    }

    return 'keep';
  }

  List<String> _decodeColors(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        return decoded.whereType<String>().toList(growable: false);
      }
    } catch (_) {
      /// إذا كانت البيانات غير صالحة نعيد قائمة فارغة بدل إيقاف التطبيق.
    }

    return const [];
  }

  /// يحول قيمة المزامنة النصية إلى enum آمن.
  ProductSyncStatus _decodeSyncStatus(String value) {
    return ProductSyncStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => ProductSyncStatus.failed,
    );
  }
}

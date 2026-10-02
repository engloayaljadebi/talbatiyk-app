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
    final now = DateTime.now();

    final currentRecord = await (database.select(
      database.productRecords,
    )..where((table) => table.id.equals(product.id))).getSingleOrNull();

    if (currentRecord == null) {
      throw StateError('المنتج غير موجود: ${product.id}');
    }

    final createOperationId = 'product:create:${product.id}';

    final pendingCreateOperation = await (database.select(
      database.syncOperations,
    )..where((table) => table.id.equals(createOperationId))).getSingleOrNull();

    // إذا لم يُرفع المنتج من قبل، نبقي العملية إنشاء بدل إرسال إنشاء ثم تعديل.
    final isWaitingForCreate = pendingCreateOperation != null;

    final nextSyncStatus = isWaitingForCreate
        ? ProductSyncStatus.pendingCreate
        : ProductSyncStatus.pendingUpdate;

    final updatedProduct = ProductModel(
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
      syncStatus: nextSyncStatus,
      syncError: null,
      createdAt: product.createdAt ?? currentRecord.createdAt,
      updatedAt: now,
    );

    await database.transaction(() async {
      // نحدّث سجل المنتج داخل قاعدة البيانات المحلية.
      await (database.update(
        database.productRecords,
      )..where((table) => table.id.equals(product.id))).write(
        ProductRecordsCompanion(
          supplierId: Value(updatedProduct.supplierId),
          supplierName: Value(updatedProduct.supplierName),
          name: Value(updatedProduct.name),
          price: Value(updatedProduct.price),
          category: Value(updatedProduct.category),
          brand: Value(updatedProduct.brand),
          description: Value(updatedProduct.description),
          colorsJson: Value(jsonEncode(updatedProduct.colors)),
          quantity: Value(updatedProduct.quantity),
          isAvailable: Value(updatedProduct.isAvailable),
          discount: Value(updatedProduct.discount),
          rating: Value(updatedProduct.rating),
          localImagePath: Value(updatedProduct.localImagePath),
          remoteImageUrl: Value(
            updatedProduct.imageUrl.trim().isEmpty
                ? null
                : updatedProduct.imageUrl,
          ),
          syncStatus: Value(updatedProduct.syncStatus.name),
          syncError: const Value(null),
          updatedAt: Value(now),
        ),
      );

      final operation = isWaitingForCreate ? 'create' : 'update';
      final operationId = 'product:$operation:${product.id}';

      // نحفظ أحدث نسخة فقط من بيانات المنتج داخل طابور المزامنة.
      await database
          .into(database.syncOperations)
          .insertOnConflictUpdate(
            SyncOperationsCompanion.insert(
              id: operationId,
              entityType: 'product',
              entityId: product.id,
              operation: operation,
              payloadJson: jsonEncode(updatedProduct.toJson()),
              createdAt: now,
            ),
          );
    });

    return updatedProduct;
  }

  /// يحذف المنتج محليًا ويسجل حذفه للسحابة عند الحاجة.
  @override
  Future<void> deleteProduct(String productId) async {
    final now = DateTime.now();

    final currentRecord = await (database.select(
      database.productRecords,
    )..where((table) => table.id.equals(productId))).getSingleOrNull();

    // الحذف عملية آمنة ويمكن استدعاؤها أكثر من مرة.
    if (currentRecord == null) {
      return;
    }

    final createOperationId = 'product:create:$productId';

    final pendingCreateOperation = await (database.select(
      database.syncOperations,
    )..where((table) => table.id.equals(createOperationId))).getSingleOrNull();

    await database.transaction(() async {
      if (pendingCreateOperation != null) {
        // المنتج لم يصل للسحابة، لذلك نحذفه نهائيًا ونلغي عملية إنشائه.
        await (database.delete(
          database.syncOperations,
        )..where((table) => table.entityId.equals(productId))).go();

        await (database.delete(
          database.productRecords,
        )..where((table) => table.id.equals(productId))).go();

        return;
      }

      // المنتج موجود سحابيًا، لذلك نخفيه محليًا حتى تُرسل عملية الحذف.
      await (database.update(
        database.productRecords,
      )..where((table) => table.id.equals(productId))).write(
        ProductRecordsCompanion(
          syncStatus: Value(ProductSyncStatus.pendingDelete.name),
          syncError: const Value(null),
          updatedAt: Value(now),
          deletedAt: Value(now),
        ),
      );

      // لم نعد بحاجة إلى عملية تعديل إذا قرر المورد حذف المنتج.
      await (database.delete(
        database.syncOperations,
      )..where((table) => table.id.equals('product:update:$productId'))).go();

      // نسجل عملية الحذف التي سترسل للسحابة عند عودة الإنترنت.
      await database
          .into(database.syncOperations)
          .insertOnConflictUpdate(
            SyncOperationsCompanion.insert(
              id: 'product:delete:$productId',
              entityType: 'product',
              entityId: productId,
              operation: 'delete',
              payloadJson: jsonEncode({
                'id': productId,
                'supplierId': currentRecord.supplierId,
                'deletedAt': now.toIso8601String(),
              }),
              createdAt: now,
            ),
          );
    });
  }

  /// يحول النص المخزن في SQLite إلى قائمة ألوان.
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

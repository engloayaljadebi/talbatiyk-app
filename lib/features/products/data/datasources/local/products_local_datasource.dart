import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../../core/database/app_database.dart';
import '../../../domain/entities/products_entity.dart';
import '../../models/products_model.dart';
import '../products_datasource.dart';

/// مصدر المنتجات المحلي المسؤول عن القراءة من قاعدة SQLite.
///
/// في أول تشغيل فقط، يضيف المنتجات التجريبية إلى قاعدة البيانات.
/// بعد ذلك تُقرأ جميع المنتجات من قاعدة البيانات المحلية.
class ProductsLocalDataSource
    implements ProductsDataSource, ProductsWritableDataSource {
  ProductsLocalDataSource(this.database);

  final AppDatabase database;

  @override
  Future<List<ProductModel>> getProducts() async {
    await _seedInitialProductsIfNeeded();

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

  /// يضيف البيانات التجريبية عند فتح قاعدة بيانات فارغة فقط.
  Future<void> _seedInitialProductsIfNeeded() async {
    final existingProduct = await (database.select(
      database.productRecords,
    )..limit(1)).getSingleOrNull();

    if (existingProduct != null) {
      return;
    }

    final now = DateTime.now();

    await database.batch((batch) {
      batch.insertAll(database.productRecords, [
        ProductRecordsCompanion.insert(
          id: '1',
          supplierId: 'demo-supplier',
          supplierName: 'مورد تجريبي',
          name: 'شاحن سامسونج وكالة',
          price: 4500,
          category: const Value('شواحن'),
          brand: const Value('Samsung'),
          description: const Value('ضمان سنة'),
          colorsJson: const Value('["أبيض","أسود"]'),
          quantity: const Value(50),
          isAvailable: const Value(true),
          rating: const Value(4.8),
          remoteImageUrl: const Value(''),
          syncStatus: const Value('synced'),
          createdAt: now,
          updatedAt: now,
        ),
        ProductRecordsCompanion.insert(
          id: '2',
          supplierId: 'demo-supplier',
          supplierName: 'مورد تجريبي',
          name: 'سماعة AirPods',
          price: 15000,
          category: const Value('سماعات'),
          brand: const Value('Apple'),
          description: const Value('نسخة أصلية'),
          colorsJson: const Value('["أبيض"]'),
          quantity: const Value(25),
          isAvailable: const Value(true),
          rating: const Value(4.7),
          remoteImageUrl: const Value(''),
          syncStatus: const Value('synced'),
          createdAt: now,
          updatedAt: now,
        ),
        ProductRecordsCompanion.insert(
          id: '3',
          supplierId: 'demo-supplier',
          supplierName: 'مورد تجريبي',
          name: 'رأس شاحن Type-C',
          price: 2500,
          category: const Value('شواحن'),
          brand: const Value('Anker'),
          quantity: const Value(0),
          isAvailable: const Value(false),
          rating: const Value(4.2),
          remoteImageUrl: const Value(''),
          syncStatus: const Value('synced'),
          createdAt: now,
          updatedAt: now,
        ),
      ]);
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

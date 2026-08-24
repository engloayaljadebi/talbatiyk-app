import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  late AppDatabase database;
  late ProductsLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ProductsLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('ProductsLocalDataSource', () {
    test('قاعدة المنتجات الفارغة تبقى فارغة ولا تضيف بيانات تجريبية', () async {
      final products = await dataSource.getProducts();

      final records = await database.select(database.productRecords).get();

      expect(products, isEmpty);
      expect(records, isEmpty);
    });

    test('يحفظ المنتج ويضيف عملية إنشاء إلى طابور المزامنة', () async {
      const productId = 'offline-product-1';
      final product = _buildProduct(id: productId);

      final savedProduct = await dataSource.createProduct(product);

      final productRecord = await (database.select(
        database.productRecords,
      )..where((table) => table.id.equals(productId))).getSingle();

      final syncOperation =
          await (database.select(
                database.syncOperations,
              )..where((table) => table.id.equals('product:create:$productId')))
              .getSingle();

      final payload =
          jsonDecode(syncOperation.payloadJson) as Map<String, dynamic>;

      expect(savedProduct.syncStatus, ProductSyncStatus.pendingCreate);
      expect(productRecord.id, productId);
      expect(productRecord.supplierId, 'supplier-1');
      expect(productRecord.localImagePath, '/local/product.jpg');
      expect(productRecord.syncStatus, ProductSyncStatus.pendingCreate.name);

      expect(syncOperation.entityType, 'product');
      expect(syncOperation.entityId, productId);
      expect(syncOperation.operation, 'create');
      expect(payload['supplierId'], 'supplier-1');
      expect(payload['localImagePath'], '/local/product.jpg');
    });

    test(
      'تعديل منتج لم يرفع بعد يحدّث عملية الإنشاء بدل إضافة عملية تعديل',
      () async {
        const productId = 'pending-update-product';

        await dataSource.createProduct(_buildProduct(id: productId));

        final updatedProduct = await dataSource.updateProduct(
          _buildProduct(id: productId, name: 'الاسم بعد التعديل', price: 1750),
        );

        final productRecord = await (database.select(
          database.productRecords,
        )..where((table) => table.id.equals(productId))).getSingle();

        final operations = await (database.select(
          database.syncOperations,
        )..where((table) => table.entityId.equals(productId))).get();

        final payload =
            jsonDecode(operations.single.payloadJson) as Map<String, dynamic>;

        expect(updatedProduct.syncStatus, ProductSyncStatus.pendingCreate);
        expect(productRecord.name, 'الاسم بعد التعديل');
        expect(productRecord.price, 1750);

        expect(operations, hasLength(1));
        expect(operations.single.operation, 'create');
        expect(payload['name'], 'الاسم بعد التعديل');
        expect(payload['price'], 1750);
      },
    );

    test('حذف منتج لم يرفع بعد يزيل المنتج ويلغي عملية الإنشاء', () async {
      const productId = 'pending-delete-product';

      await dataSource.createProduct(_buildProduct(id: productId));

      await dataSource.deleteProduct(productId);

      final productRecord = await (database.select(
        database.productRecords,
      )..where((table) => table.id.equals(productId))).getSingleOrNull();

      final operations = await (database.select(
        database.syncOperations,
      )..where((table) => table.entityId.equals(productId))).get();

      expect(productRecord, isNull);
      expect(operations, isEmpty);
    });

    test('حذف منتج متزامن يخفيه محليًا ويضيف عملية حذف', () async {
      const productId = 'synced-product-1';
      final createdAt = DateTime.utc(2026, 8, 4, 12);

      // هذا سجل إدارة مورد متزامن صريح، وليس Discovery cache.
      await database
          .into(database.productRecords)
          .insert(
            ProductRecordsCompanion.insert(
              id: productId,
              supplierId: 'supplier-1',
              supplierName: 'المورد الحقيقي',
              name: 'منتج متزامن',
              price: 1250,
              category: const Value('مواد غذائية'),
              brand: const Value('علامة حقيقية'),
              description: const Value('منتج متزامن للاختبار'),
              quantity: const Value(20),
              isAvailable: const Value(true),
              syncStatus: Value(ProductSyncStatus.synced.name),
              createdAt: createdAt,
              updatedAt: createdAt,
            ),
          );

      await dataSource.deleteProduct(productId);

      final productRecord = await (database.select(
        database.productRecords,
      )..where((table) => table.id.equals(productId))).getSingle();

      final deleteOperation =
          await (database.select(
                database.syncOperations,
              )..where((table) => table.id.equals('product:delete:$productId')))
              .getSingle();

      final visibleProducts = await dataSource.getProducts();

      expect(productRecord.deletedAt, isNotNull);
      expect(productRecord.syncStatus, ProductSyncStatus.pendingDelete.name);
      expect(deleteOperation.operation, 'delete');
      expect(
        visibleProducts.any((product) => product.id == productId),
        isFalse,
      );
    });
  });
}

ProductModel _buildProduct({
  required String id,
  String name = 'منتج محفوظ بدون إنترنت',
  double price = 1250,
}) {
  final createdAt = DateTime.utc(2026, 8, 4, 12);

  return ProductModel(
    id: id,
    supplierId: 'supplier-1',
    supplierName: 'المورد التجريبي',
    name: name,
    price: price,
    imageUrl: '',
    localImagePath: '/local/product.jpg',
    category: 'مواد غذائية',
    brand: 'علامة تجريبية',
    isAvailable: true,
    description: 'منتج لاختبار الحفظ المحلي',
    colors: const ['أحمر', 'أبيض'],
    quantity: 20,
    discount: 0,
    rating: 0,
    createdAt: createdAt,
    updatedAt: createdAt,
  );
}

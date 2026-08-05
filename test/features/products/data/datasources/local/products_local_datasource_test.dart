import 'dart:convert';

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
    // قاعدة مؤقتة مستقلة لكل اختبار ولا تكتب شيئًا على الهاتف.
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ProductsLocalDataSource(database);
  });

  tearDown(() async {
    // نغلق قاعدة البيانات لمنع بقاء اتصالات أو مؤقتات مفتوحة.
    await database.close();
  });

  group('ProductsLocalDataSource', () {
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

        // المنتج الجديد يبقى بانتظار الإنشاء السحابي.
        expect(updatedProduct.syncStatus, ProductSyncStatus.pendingCreate);
        expect(productRecord.name, 'الاسم بعد التعديل');
        expect(productRecord.price, 1750);

        // يجب وجود عملية إنشاء واحدة فقط تحمل أحدث البيانات.
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

      // لا حاجة لإرسال حذف للسحابة لأن المنتج لم يصل إليها أصلًا.
      expect(productRecord, isNull);
      expect(operations, isEmpty);
    });

    test('حذف منتج متزامن يخفيه محليًا ويضيف عملية حذف', () async {
      // تحميل المنتجات لأول مرة يضيف المنتجات التجريبية المتزامنة.
      await dataSource.getProducts();

      await dataSource.deleteProduct('1');

      final productRecord = await (database.select(
        database.productRecords,
      )..where((table) => table.id.equals('1'))).getSingle();

      final deleteOperation = await (database.select(
        database.syncOperations,
      )..where((table) => table.id.equals('product:delete:1'))).getSingle();

      final visibleProducts = await dataSource.getProducts();

      // يبقى السجل حتى يُرسل الحذف، لكنه لا يظهر في قائمة المنتجات.
      expect(productRecord.deletedAt, isNotNull);
      expect(productRecord.syncStatus, ProductSyncStatus.pendingDelete.name);
      expect(deleteOperation.operation, 'delete');
      expect(visibleProducts.any((product) => product.id == '1'), isFalse);
    });
  });
}

/// ينشئ نموذج منتج موحدًا لاستخدامه داخل الاختبارات.
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

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
    // ننشئ قاعدة بيانات مؤقتة في الذاكرة لكل اختبار.
    // لا يكتب هذا الاختبار أي بيانات حقيقية على الهاتف.
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = ProductsLocalDataSource(database);
  });

  tearDown(() async {
    // نغلق قاعدة البيانات بعد كل اختبار لمنع بقاء مؤقتات أو اتصالات مفتوحة.
    await database.close();
  });

  group('ProductsLocalDataSource.createProduct', () {
    test('يحفظ المنتج محليًا ويضيف عملية إنشاء إلى طابور المزامنة', () async {
      const productId = 'offline-product-1';
      final createdAt = DateTime.utc(2026, 8, 4, 12);

      final product = ProductModel(
        id: productId,
        supplierId: 'supplier-1',
        supplierName: 'المورد التجريبي',
        name: 'منتج محفوظ بدون إنترنت',
        price: 1250,
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

      // نحفظ المنتج باستخدام نفس مصدر البيانات المستخدم داخل التطبيق.
      final savedProduct = await dataSource.createProduct(product);

      // نقرأ سجل المنتج مباشرة من قاعدة البيانات.
      final productRecord = await (database.select(
        database.productRecords,
      )..where((table) => table.id.equals(productId))).getSingle();

      // نقرأ عملية المزامنة الخاصة بالمنتج.
      final syncOperation =
          await (database.select(
                database.syncOperations,
              )..where((table) => table.id.equals('product:create:$productId')))
              .getSingle();

      final payload =
          jsonDecode(syncOperation.payloadJson) as Map<String, dynamic>;

      // نتأكد أن المنتج أُعيد بحالة انتظار الرفع.
      expect(savedProduct.syncStatus, ProductSyncStatus.pendingCreate);

      // نتأكد أن بيانات المنتج حُفظت محليًا بشكل صحيح.
      expect(productRecord.id, productId);
      expect(productRecord.supplierId, 'supplier-1');
      expect(productRecord.name, 'منتج محفوظ بدون إنترنت');
      expect(productRecord.localImagePath, '/local/product.jpg');
      expect(productRecord.syncStatus, ProductSyncStatus.pendingCreate.name);

      // نتأكد أن طابور المزامنة يحتوي على عملية إنشاء واحدة صحيحة.
      expect(syncOperation.entityType, 'product');
      expect(syncOperation.entityId, productId);
      expect(syncOperation.operation, 'create');

      // نتأكد أن البيانات التي سترسل للسحابة تحتوي على المورد والصورة.
      expect(payload['supplierId'], 'supplier-1');
      expect(payload['supplierName'], 'المورد التجريبي');
      expect(payload['localImagePath'], '/local/product.jpg');
    });
  });
}

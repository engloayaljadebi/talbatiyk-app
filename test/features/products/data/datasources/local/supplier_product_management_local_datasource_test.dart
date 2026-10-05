import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'server refresh does not overwrite a pending local Product update',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final local = ProductsLocalDataSource(database);

      const id = 'product-update';
      const businessId = 'business-1';

      await local.upsertSyncedProduct(
        _product(
          id: id,
          businessId: businessId,
          name: 'Server',
          quantity: 5,
          version: 3,
        ),
      );

      await local.updateProduct(
        _product(
          id: id,
          businessId: businessId,
          name: 'Local pending',
          quantity: 99,
          version: 3,
        ),
      );

      final visible = await local.reconcileBusinessProducts(
        businessId: businessId,
        serverProducts: <ProductModel>[
          _product(
            id: id,
            businessId: businessId,
            name: 'Server',
            quantity: 5,
            version: 3,
          ),
        ],
      );

      expect(visible, hasLength(1));
      expect(visible.single.name, 'Local pending');
      expect(visible.single.quantity, 99);

      expect(visible.single.syncStatus, ProductSyncStatus.pendingUpdate);

      final operation = await (database.select(
        database.syncOperations,
      )..where((row) => row.id.equals('product:update:$id'))).getSingleOrNull();

      expect(operation != null, isTrue);
    },
  );

  test('server refresh never resurrects a locally pending delete', () async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());

    addTearDown(database.close);

    final local = ProductsLocalDataSource(database);

    const id = 'product-delete';
    const businessId = 'business-1';

    final product = _product(
      id: id,
      businessId: businessId,
      name: 'Delete me',
      quantity: 5,
      version: 7,
    );

    await local.upsertSyncedProduct(product);
    await local.deleteProduct(id);

    final visible = await local.reconcileBusinessProducts(
      businessId: businessId,
      serverProducts: <ProductModel>[product],
    );

    expect(visible, isEmpty);

    final row = await (database.select(
      database.productRecords,
    )..where((table) => table.id.equals(id))).getSingle();

    expect(row.syncStatus, ProductSyncStatus.pendingDelete.name);

    expect(row.deletedAt != null, isTrue);
  });

  test(
    'clean local Product missing from complete server list is removed as stale',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final local = ProductsLocalDataSource(database);

      const id = 'stale-product';
      const businessId = 'business-1';

      await local.upsertSyncedProduct(
        _product(
          id: id,
          businessId: businessId,
          name: 'Stale',
          quantity: 1,
          version: 2,
        ),
      );

      final visible = await local.reconcileBusinessProducts(
        businessId: businessId,
        serverProducts: const <ProductModel>[],
      );

      expect(visible, isEmpty);

      final row = await (database.select(
        database.productRecords,
      )..where((table) => table.id.equals(id))).getSingleOrNull();

      expect(row == null, isTrue);
    },
  );
}

ProductModel _product({
  required String id,
  required String businessId,
  required String name,
  required int quantity,
  required int version,
}) {
  return ProductModel(
    id: id,
    supplierId: businessId,
    supplierName: 'Managed Supplier',
    name: name,
    price: 100,
    imageUrl: '',
    serverVersion: version,
    category: 'Tests',
    brand: 'Talbatiyk',
    isAvailable: true,
    description: 'Test Product',
    quantity: quantity,
    createdAt: DateTime.utc(2026, 10, 6),
    updatedAt: DateTime.utc(2026, 10, 6),
  );
}

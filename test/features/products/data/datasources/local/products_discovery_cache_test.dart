import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_discovery_local_datasource.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  late AppDatabase database;
  late ProductsDiscoveryLocalDataSource discoveryDataSource;
  late ProductsLocalDataSource managementDataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    discoveryDataSource = ProductsDiscoveryLocalDataSource(database);
    managementDataSource = ProductsLocalDataSource(database);
  });

  tearDown(() async {
    await database.close();
  });

  group('Products discovery cache', () {
    test('empty discovery cache remains empty', () async {
      final products = await discoveryDataSource.getCachedProducts();

      final discoveryRecords = await database
          .select(database.productDiscoveryRecords)
          .get();

      expect(products, isEmpty);
      expect(discoveryRecords, isEmpty);
    });

    test(
      'stores remote snapshot as synced cache without creating outbox work',
      () async {
        await discoveryDataSource.replaceCachedProducts([
          _buildProduct(
            id: 'server-product-1',
            name: 'Server product',
            imageUrl: 'https://example.test/product.jpg',
            createdAt: null,
            updatedAt: null,
          ),
        ]);

        final cachedProducts = await discoveryDataSource.getCachedProducts();

        expect(cachedProducts, hasLength(1));

        final cachedProduct = cachedProducts.single;

        expect(cachedProduct.id, 'server-product-1');
        expect(cachedProduct.name, 'Server product');
        expect(cachedProduct.syncStatus, ProductSyncStatus.synced);
        expect(cachedProduct.imageUrl, 'https://example.test/product.jpg');
        expect(cachedProduct.createdAt, isNotNull);
        expect(cachedProduct.updatedAt, isNotNull);

        final managementRecords = await database
            .select(database.productRecords)
            .get();

        final operations = await database.select(database.syncOperations).get();

        expect(managementRecords, isEmpty);
        expect(operations, isEmpty);
      },
    );

    test(
      'replaces only discovery snapshot and never mutates supplier pending work',
      () async {
        // Same ID intentionally exists in supplier management and Discovery.
        // The two stores must remain completely independent.
        await managementDataSource.createProduct(
          _buildProduct(
            id: 'shared-product',
            name: 'Supplier pending version',
            supplierId: 'supplier-local',
            supplierName: 'Local Supplier',
          ),
        );

        await discoveryDataSource.replaceCachedProducts([
          _buildProduct(
            id: 'stale-server-product',
            name: 'Stale remote product',
          ),
          _buildProduct(
            id: 'shared-product',
            name: 'Remote version one',
            supplierId: 'supplier-remote',
            supplierName: 'Remote Supplier',
          ),
        ]);

        await discoveryDataSource.replaceCachedProducts([
          _buildProduct(
            id: 'shared-product',
            name: 'Remote version two',
            supplierId: 'supplier-remote',
            supplierName: 'Remote Supplier',
          ),
          _buildProduct(
            id: 'fresh-server-product',
            name: 'Fresh remote product',
          ),
          // Duplicate server IDs are collapsed defensively.
          _buildProduct(
            id: 'fresh-server-product',
            name: 'Fresh remote product latest',
          ),
        ]);

        final managementRecord = await (database.select(
          database.productRecords,
        )..where((table) => table.id.equals('shared-product'))).getSingle();

        expect(managementRecord.name, 'Supplier pending version');
        expect(managementRecord.supplierId, 'supplier-local');
        expect(
          managementRecord.syncStatus,
          ProductSyncStatus.pendingCreate.name,
        );

        final operations = await database.select(database.syncOperations).get();

        expect(operations, hasLength(1));
        expect(operations.single.entityId, 'shared-product');
        expect(operations.single.operation, 'create');

        final cache = await discoveryDataSource.getCachedProducts();

        expect(cache, hasLength(2));

        final cacheById = {for (final product in cache) product.id: product};

        expect(cacheById.containsKey('stale-server-product'), isFalse);
        expect(cacheById['shared-product']?.name, 'Remote version two');
        expect(
          cacheById['fresh-server-product']?.name,
          'Fresh remote product latest',
        );
      },
    );
  });
}

ProductModel _buildProduct({
  required String id,
  required String name,
  String supplierId = 'supplier-1',
  String supplierName = 'Supplier One',
  String imageUrl = '',
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  return ProductModel(
    id: id,
    supplierId: supplierId,
    supplierName: supplierName,
    name: name,
    price: 1250,
    imageUrl: imageUrl,
    category: 'Electronics',
    brand: 'Test Brand',
    isAvailable: true,
    description: 'Product used by Discovery cache tests.',
    colors: const ['Black'],
    quantity: 10,
    discount: 0,
    rating: 4.5,
    syncStatus: ProductSyncStatus.synced,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );
}

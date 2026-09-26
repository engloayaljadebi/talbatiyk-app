import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/products/data/datasources/local/products_local_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';

void main() {
  test(
    'product publish attempt survives datasource recreation and creates no outbox',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      const idempotencyKey = '33333333-3333-4333-8333-333333333333';

      const product = ProductModel(
        id: '44444444-4444-4444-8444-444444444444',
        supplierId: '55555555-5555-4555-8555-555555555555',
        supplierName: 'Supplier',
        name: 'Durable Product',
        price: 1500,
        imageUrl: '',
        localImagePath: '/tmp/durable-product.jpg',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        description: 'Durable publish attempt',
        quantity: 4,
      );

      final firstDataSource = ProductsLocalDataSource(database);

      final firstAttempt = await firstDataSource.preparePublishAttempt(
        product: product,
        idempotencyKey: idempotencyKey,
      );

      expect(firstAttempt.idempotencyKey, idempotencyKey);

      /*
       * Publishing attempts are NOT product:create Outbox operations.
       */
      expect(await database.select(database.syncOperations).get(), isEmpty);

      /*
       * A new datasource instance simulates process/repository recreation.
       */
      final afterRestart = ProductsLocalDataSource(database);

      final recovered = await afterRestart.getRetryablePublishAttempts();

      expect(recovered, hasLength(1));
      expect(recovered.single.idempotencyKey, idempotencyKey);
      expect(recovered.single.product.id, product.id);

      /*
       * Supplying another random candidate key for the same logical
       * clientProductId must recover the original key.
       */
      final reused = await afterRestart.preparePublishAttempt(
        product: product,
        idempotencyKey: '66666666-6666-4666-8666-666666666666',
      );

      expect(reused.idempotencyKey, idempotencyKey);

      const serverProduct = ProductModel(
        id: '77777777-7777-4777-8777-777777777777',
        supplierId: '55555555-5555-4555-8555-555555555555',
        supplierName: 'Supplier',
        name: 'Durable Product',
        price: 1500,
        imageUrl: 'https://example.test/product.jpg',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        description: 'Durable publish attempt',
        quantity: 4,
      );

      await afterRestart.upsertSyncedProduct(serverProduct);

      await afterRestart.completePublishAttempt(idempotencyKey);

      final products = await database.select(database.productRecords).get();

      expect(products, hasLength(1));
      expect(products.single.id, serverProduct.id);
      expect(products.single.syncStatus, 'synced');

      expect(
        await database.select(database.productPublishAttemptRecords).get(),
        isEmpty,
      );

      expect(await database.select(database.syncOperations).get(), isEmpty);
    },
  );

  test(
    'same client publish identity cannot silently change its payload',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final dataSource = ProductsLocalDataSource(database);

      const first = ProductModel(
        id: '88888888-8888-4888-8888-888888888888',
        supplierId: '99999999-9999-4999-8999-999999999999',
        supplierName: 'Supplier',
        name: 'Payload A',
        price: 1000,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Brand',
        isAvailable: true,
        quantity: 1,
      );

      await dataSource.preparePublishAttempt(
        product: first,
        idempotencyKey: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
      );

      const changed = ProductModel(
        id: '88888888-8888-4888-8888-888888888888',
        supplierId: '99999999-9999-4999-8999-999999999999',
        supplierName: 'Supplier',
        name: 'Payload B',
        price: 1000,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Brand',
        isAvailable: true,
        quantity: 1,
      );

      await expectLater(
        () => dataSource.preparePublishAttempt(
          product: changed,
          idempotencyKey: 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
        ),
        throwsA(isA<StateError>()),
      );

      expect(
        await database.select(database.productPublishAttemptRecords).get(),
        hasLength(1),
      );

      expect(await database.select(database.syncOperations).get(), isEmpty);
    },
  );
}

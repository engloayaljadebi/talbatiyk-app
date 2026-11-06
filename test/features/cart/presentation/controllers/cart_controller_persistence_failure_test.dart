import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'flushPersistence reports failure and recovers on the next snapshot',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      final dataSource = CartLocalDataSource(
        database,
        ownerUserId: 'persistence-failure-test-user',
      );

      final controller = CartController(localDataSource: dataSource);

      addTearDown(controller.dispose);

      await controller.ready;

      await database.customStatement('''
        CREATE TRIGGER fail_cart_catalog_insert
        BEFORE INSERT ON cart_item_records
        WHEN NEW.kind = 'catalog'
        BEGIN
          SELECT RAISE(ABORT, 'forced persistence failure');
        END;
      ''');

      expect(controller.addProduct(_product), CartAddResult.added);

      await expectLater(controller.flushPersistence(), throwsA(anything));

      final failedItems = await dataSource.getItemsForCart(
        controller.activeCartId!,
      );

      expect(failedItems, isEmpty);

      await database.customStatement('DROP TRIGGER fail_cart_catalog_insert;');

      expect(controller.addProduct(_product), CartAddResult.added);

      await controller.flushPersistence();

      final recoveredItems = await dataSource.getItemsForCart(
        controller.activeCartId!,
      );

      expect(recoveredItems, hasLength(1));
      expect(recoveredItems.single.quantity, 2);
    },
  );
}

const _product = ProductEntity(
  id: 'persistence-failure-product',
  supplierId: 'supplier-1',
  supplierName: 'Supplier',
  name: 'Persistence test product',
  price: 1500,
  imageUrl: '',
  category: 'Test',
  brand: 'Test',
  isAvailable: true,
);

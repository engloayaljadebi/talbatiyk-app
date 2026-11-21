import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbytk/core/database/app_database.dart';
import 'package:talbytk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbytk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbytk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbytk/features/products/domain/entities/products_entity.dart';

void main() {
  group('Cart item unified price', () {
    test('manual item requires one unit price and calculates its total', () {
      final item = CartItemEntity.manual(
        id: 'manual-priced',
        name: 'Packaging bags',
        unitPrice: 125,
        quantity: 4,
      );

      expect(item.isManual, isTrue);
      expect(item.unitPrice, 125);
      expect(item.totalPrice, 500);
      expect(item.catalogProductId, isNull);
    });

    test('rejects negative unit price', () {
      expect(
        () => CartItemEntity.manual(
          id: 'invalid-price',
          name: 'Invalid item',
          unitPrice: -1,
          quantity: 1,
        ),
        throwsArgumentError,
      );
    });

    test('rejects non-finite unit price', () {
      expect(
        () => CartItemEntity.manual(
          id: 'invalid-price',
          name: 'Invalid item',
          unitPrice: double.infinity,
          quantity: 1,
        ),
        throwsArgumentError,
      );
    });

    test('allows a zero price as an explicitly supplied price', () {
      final item = CartItemEntity.manual(
        id: 'zero-price',
        name: 'Free sample',
        unitPrice: 0,
        quantity: 2,
      );

      expect(item.unitPrice, 0);
      expect(item.totalPrice, 0);
    });
  });

  test(
    'controller calculates one total for catalog and manual items',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      final dataSource = CartLocalDataSource(
        database,
        ownerUserId: 'unified-price-test',
      );

      final cart = await dataSource.createCartAndActivate('Unified price');

      const catalogProduct = ProductEntity(
        id: 'catalog-price-test',
        name: 'Catalog item',
        price: 100,
        imageUrl: '',
        category: '',
        brand: '',
        isAvailable: true,
      );

      await dataSource.replaceAllItemsForCart(cart.id, [
        const CartItemEntity(product: catalogProduct, quantity: 2),
      ]);

      final controller = CartController(localDataSource: dataSource);
      addTearDown(controller.dispose);

      await controller.ready;

      expect(controller.totalPrice, 200);

      final manualId = controller.addManualItem(
        name: 'Manual item',
        unitPrice: 250,
        quantity: 3,
      );

      expect(manualId, isNotNull);
      expect(controller.totalPrice, 950);

      final updated = await controller.updateManualItem(
        id: manualId!,
        name: 'Updated manual item',
        unitPrice: 300,
        quantity: 3,
      );

      expect(updated, isTrue);
      expect(controller.totalPrice, 1100);

      await controller.flushPersistence();

      final saved = await dataSource.getItemsForCart(cart.id);

      expect(saved, hasLength(2));
      expect(saved.firstWhere((item) => item.isManual).totalPrice, 900);
    },
  );
}

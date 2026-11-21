import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbytk/core/database/app_database.dart';
import 'package:talbytk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbytk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbytk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbytk/features/products/domain/entities/products_entity.dart';

void main() {
  late AppDatabase database;
  late CartLocalDataSource dataSource;

  setUp(() {
    database = AppDatabase.forTesting(NativeDatabase.memory());
    dataSource = CartLocalDataSource(
      database,
      ownerUserId: 'manual-controller-test',
    );
  });

  tearDown(() async {
    await database.close();
  });

  test(
    'adds before restore, updates, persists and removes manual item',
    () async {
      final cart = await dataSource.createCartAndActivate('Manual operations');
      final controller = CartController(localDataSource: dataSource);
      addTearDown(controller.dispose);

      // This mutation intentionally occurs before the initial restore finishes.
      final manualId = controller.addManualItem(
        name: 'Packaging bags',
        unitPrice: 250,
        quantity: 2,
        unit: 'box',
        note: 'Initial note',
      );

      expect(manualId, isNotNull);

      await controller.ready;

      final id = manualId!;

      expect(controller.items, hasLength(1));
      expect(controller.items.single.isManual, isTrue);
      expect(controller.quantityOfManualItem(id), 2);

      controller.increaseManualItem(id);
      expect(controller.quantityOfManualItem(id), 3);

      controller.decreaseManualItem(id);
      expect(controller.quantityOfManualItem(id), 2);

      final updated = await controller.updateManualItem(
        id: id,
        name: 'Updated packaging bags',
        unitPrice: 325,
        quantity: 4,
        unit: null,
        note: null,
      );

      expect(updated, isTrue);
      expect(controller.items.single.product.name, 'Updated packaging bags');
      expect(controller.items.single.unitPrice, 325);
      expect(controller.items.single.quantity, 4);
      expect(controller.items.single.unit, isNull);
      expect(controller.items.single.note, isNull);

      await controller.flushPersistence();

      final saved = await dataSource.getItemsForCart(cart.id);

      expect(saved, hasLength(1));
      expect(saved.single.id, id);
      expect(saved.single.isManual, isTrue);
      expect(saved.single.quantity, 4);
      expect(saved.single.unitPrice, 325);
      expect(saved.single.unit, isNull);
      expect(saved.single.note, isNull);

      controller.removeManualItem(id);
      await controller.flushPersistence();

      expect(await dataSource.getItemsForCart(cart.id), isEmpty);
    },
  );

  test('manual and catalog items remain separate when IDs match', () async {
    final cart = await dataSource.createCartAndActivate('Identity test');

    const catalogProduct = ProductEntity(
      id: 'shared-id',
      name: 'Catalog item',
      price: 100,
      imageUrl: '',
      category: '',
      brand: '',
      isAvailable: true,
    );

    await dataSource.replaceAllItemsForCart(cart.id, [
      const CartItemEntity(product: catalogProduct, quantity: 2),
      CartItemEntity.manual(
        id: 'shared-id',
        name: 'Manual item',
        unitPrice: 250,
        quantity: 3,
      ),
    ]);

    final controller = CartController(localDataSource: dataSource);
    addTearDown(controller.dispose);

    await controller.ready;

    expect(controller.items, hasLength(2));
    expect(controller.quantityOf('shared-id'), 2);
    expect(controller.quantityOfManualItem('shared-id'), 3);

    controller.decreaseManualItem('shared-id');
    await controller.flushPersistence();

    expect(controller.quantityOf('shared-id'), 2);
    expect(controller.quantityOfManualItem('shared-id'), 2);

    controller.removeManualItem('shared-id');
    await controller.flushPersistence();

    final remaining = await dataSource.getItemsForCart(cart.id);

    expect(remaining, hasLength(1));
    expect(remaining.single.isManual, isFalse);
    expect(remaining.single.product.id, 'shared-id');
    expect(remaining.single.quantity, 2);
  });
}

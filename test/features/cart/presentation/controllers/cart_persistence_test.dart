import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test('cart survives database close and application reopen', () async {
    final tempDirectory = await Directory.systemTemp.createTemp(
      'talbatiyk-cart-persistence-',
    );

    final databaseFile = File(
      '${tempDirectory.path}${Platform.pathSeparator}talbatiyk.sqlite',
    );

    addTearDown(() async {
      if (await tempDirectory.exists()) {
        await tempDirectory.delete(recursive: true);
      }
    });

    final firstDatabase = AppDatabase.forTesting(NativeDatabase(databaseFile));

    final firstController = CartController(
      localDataSource: CartLocalDataSource(firstDatabase),
    );

    await firstController.ready;

    expect(firstController.addProduct(_product), CartAddResult.added);
    expect(firstController.addProduct(_product), CartAddResult.added);

    await firstController.flushPersistence();

    expect(firstController.quantityOf(_product.id), 2);

    await firstDatabase.close();

    final reopenedDatabase = AppDatabase.forTesting(
      NativeDatabase(databaseFile),
    );

    final reopenedController = CartController(
      localDataSource: CartLocalDataSource(reopenedDatabase),
    );

    await reopenedController.ready;

    expect(reopenedController.items, hasLength(1));
    expect(reopenedController.quantityOf(_product.id), 2);
    expect(reopenedController.supplierId, 'supplier-1');
    expect(reopenedController.totalPrice, 9000);

    reopenedController.clear();

    await reopenedController.flushPersistence();
    await reopenedDatabase.close();

    final thirdDatabase = AppDatabase.forTesting(NativeDatabase(databaseFile));

    addTearDown(thirdDatabase.close);

    final thirdController = CartController(
      localDataSource: CartLocalDataSource(thirdDatabase),
    );

    await thirdController.ready;

    expect(thirdController.isEmpty, isTrue);
  });
}

const ProductEntity _product = ProductEntity(
  id: 'cart-product-1',
  supplierId: 'supplier-1',
  supplierName: 'Persistent Supplier',
  name: 'Persistent Charger',
  price: 4500,
  imageUrl: 'https://example.test/charger.jpg',
  category: 'Chargers',
  brand: 'Talbatiyk',
  isAvailable: true,
  description: 'Persistent cart test product.',
  colors: ['Black'],
  quantity: 10,
  rating: 4.8,
);

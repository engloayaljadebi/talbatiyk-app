import 'package:flutter_test/flutter_test.dart';
import 'package:talbytk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbytk/features/products/domain/entities/products_entity.dart';

void main() {
  group('CartItemEntity', () {
    const catalogProduct = ProductEntity(
      id: 'product-1',
      name: 'Catalog product',
      price: 1500,
      imageUrl: '',
      category: '',
      brand: '',
      isAvailable: true,
    );

    test('catalog items preserve existing constructor behavior', () {
      const item = CartItemEntity(product: catalogProduct, quantity: 2);

      expect(item.kind, CartItemKind.catalog);
      expect(item.isManual, isFalse);
      expect(item.id, 'product-1');
      expect(item.catalogProductId, 'product-1');
      expect(item.unitPrice, 1500);
      expect(item.totalPrice, 3000);
    });

    test('manual item requires name, ID, price and positive quantity', () {
      final item = CartItemEntity.manual(
        id: 'manual-1',
        name: 'Packaging bags',
        unitPrice: 250,
        quantity: 4,
        unit: 'piece',
        note: 'Large size',
      );

      expect(item.kind, CartItemKind.manual);
      expect(item.isManual, isTrue);
      expect(item.id, 'manual-1');
      expect(item.catalogProductId, isNull);
      expect(item.product.id, 'manual-1');
      expect(item.product.name, 'Packaging bags');
      expect(item.unitPrice, 250);
      expect(item.quantity, 4);
      expect(item.totalPrice, 1000);
      expect(item.unit, 'piece');
      expect(item.note, 'Large size');
    });

    test('manual item trims optional text', () {
      final item = CartItemEntity.manual(
        id: 'manual-2',
        name: '  Item name  ',
        unitPrice: 100,
        quantity: 1,
        unit: '  box  ',
        note: '  note  ',
      );

      expect(item.product.name, 'Item name');
      expect(item.unit, 'box');
      expect(item.note, 'note');
    });

    test('manual item rejects empty ID', () {
      expect(
        () => CartItemEntity.manual(
          id: ' ',
          name: 'Item',
          unitPrice: 100,
          quantity: 1,
        ),
        throwsArgumentError,
      );
    });

    test('manual item rejects empty name', () {
      expect(
        () => CartItemEntity.manual(
          id: 'manual-3',
          name: ' ',
          unitPrice: 100,
          quantity: 1,
        ),
        throwsArgumentError,
      );
    });

    test('manual item rejects invalid price', () {
      expect(
        () => CartItemEntity.manual(
          id: 'manual-4',
          name: 'Item',
          unitPrice: double.nan,
          quantity: 1,
        ),
        throwsArgumentError,
      );

      expect(
        () => CartItemEntity.manual(
          id: 'manual-5',
          name: 'Item',
          unitPrice: -1,
          quantity: 1,
        ),
        throwsArgumentError,
      );
    });

    test('manual item rejects zero quantity', () {
      expect(
        () => CartItemEntity.manual(
          id: 'manual-6',
          name: 'Item',
          unitPrice: 100,
          quantity: 0,
        ),
        throwsArgumentError,
      );
    });

    test('copyWith preserves manual identity and details', () {
      final item = CartItemEntity.manual(
        id: 'manual-7',
        name: 'Item',
        unitPrice: 100,
        quantity: 2,
        unit: 'box',
        note: 'Fragile',
      );

      final updated = item.copyWith(quantity: 5);

      expect(updated.isManual, isTrue);
      expect(updated.id, 'manual-7');
      expect(updated.quantity, 5);
      expect(updated.unit, 'box');
      expect(updated.note, 'Fragile');
      expect(updated.totalPrice, 500);
    });
  });
}

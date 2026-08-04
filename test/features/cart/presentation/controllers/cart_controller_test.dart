import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  const availableProduct = ProductEntity(
    id: 'product-1',
    name: 'منتج متوفر',
    price: 4500,
    imageUrl: '',
    category: 'اختبار',
    brand: 'طلبيتك',
    isAvailable: true,
  );

  const unavailableProduct = ProductEntity(
    id: 'product-2',
    name: 'منتج غير متوفر',
    price: 2500,
    imageUrl: '',
    category: 'اختبار',
    brand: 'طلبيتك',
    isAvailable: false,
  );

  group('CartController', () {
    test('adds products and calculates totals', () {
      final controller = CartController();

      controller.addProduct(availableProduct);
      controller.addProduct(availableProduct);

      expect(controller.items, hasLength(1));
      expect(controller.quantityOf(availableProduct.id), 2);
      expect(controller.totalQuantity, 2);
      expect(controller.totalPrice, 9000);
    });

    test('ignores unavailable products', () {
      final controller = CartController();

      controller.addProduct(unavailableProduct);

      expect(controller.isEmpty, isTrue);
    });

    test('decreases quantity and removes the last unit', () {
      final controller = CartController();

      controller.addProduct(availableProduct);
      controller.addProduct(availableProduct);
      controller.decreaseProduct(availableProduct.id);

      expect(controller.quantityOf(availableProduct.id), 1);

      controller.decreaseProduct(availableProduct.id);

      expect(controller.isEmpty, isTrue);
    });
  });
}

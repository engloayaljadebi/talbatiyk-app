import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  const ProductEntity firstSupplierProduct = ProductEntity(
    id: 'product-1',
    supplierId: 'supplier-1',
    supplierName: 'مؤسسة الأمل',
    name: 'شاحن سريع',
    price: 4500,
    imageUrl: '',
    category: 'شواحن',
    brand: 'طلبيتك',
    isAvailable: true,
  );

  const ProductEntity secondProductFromSameSupplier = ProductEntity(
    id: 'product-2',
    supplierId: 'supplier-1',
    supplierName: 'مؤسسة الأمل',
    name: 'سماعة لاسلكية',
    price: 8000,
    imageUrl: '',
    category: 'سماعات',
    brand: 'طلبيتك',
    isAvailable: true,
  );

  const ProductEntity differentSupplierProduct = ProductEntity(
    id: 'product-3',
    supplierId: 'supplier-2',
    supplierName: 'متجر التقنية',
    name: 'هاتف ذكي',
    price: 120000,
    imageUrl: '',
    category: 'هواتف',
    brand: 'طلبيتك',
    isAvailable: true,
  );

  const ProductEntity unavailableProduct = ProductEntity(
    id: 'product-4',
    supplierId: 'supplier-1',
    supplierName: 'مؤسسة الأمل',
    name: 'منتج غير متوفر',
    price: 2500,
    imageUrl: '',
    category: 'اختبار',
    brand: 'طلبيتك',
    isAvailable: false,
  );

  group('CartController', () {
    test('adds products and calculates totals', () {
      final CartController controller = CartController();

      final CartAddResult firstResult = controller.addProduct(
        firstSupplierProduct,
      );

      final CartAddResult secondResult = controller.addProduct(
        firstSupplierProduct,
      );

      expect(firstResult, CartAddResult.added);
      expect(secondResult, CartAddResult.added);
      expect(controller.items, hasLength(1));
      expect(controller.quantityOf(firstSupplierProduct.id), 2);
      expect(controller.totalQuantity, 2);
      expect(controller.totalPrice, 9000);
    });

    test('returns unavailable when product is not available', () {
      final CartController controller = CartController();

      final CartAddResult result = controller.addProduct(unavailableProduct);

      expect(result, CartAddResult.unavailable);
      expect(controller.isEmpty, isTrue);
    });

    test('decreases quantity and removes the last unit', () {
      final CartController controller = CartController();

      controller.addProduct(firstSupplierProduct);
      controller.addProduct(firstSupplierProduct);

      controller.decreaseProduct(firstSupplierProduct.id);

      expect(controller.quantityOf(firstSupplierProduct.id), 1);

      controller.decreaseProduct(firstSupplierProduct.id);

      expect(controller.isEmpty, isTrue);
    });

    test('accepts different products from the same supplier', () {
      final CartController controller = CartController();

      final CartAddResult firstResult = controller.addProduct(
        firstSupplierProduct,
      );

      final CartAddResult secondResult = controller.addProduct(
        secondProductFromSameSupplier,
      );

      expect(firstResult, CartAddResult.added);
      expect(secondResult, CartAddResult.added);
      expect(controller.items, hasLength(2));
      expect(controller.hasSingleSupplier, isTrue);
      expect(controller.supplierId, 'supplier-1');
      expect(controller.supplierName, 'مؤسسة الأمل');
      expect(controller.totalPrice, 12500);
    });

    test('accepts products from different suppliers', () {
      final CartController controller = CartController();

      final CartAddResult firstResult = controller.addProduct(
        firstSupplierProduct,
      );

      final CartAddResult secondResult = controller.addProduct(
        differentSupplierProduct,
      );

      expect(firstResult, CartAddResult.added);
      expect(secondResult, CartAddResult.added);

      expect(controller.items, hasLength(2));
      expect(controller.quantityOf(firstSupplierProduct.id), 1);
      expect(controller.quantityOf(differentSupplierProduct.id), 1);

      // Multi-Supplier Cart حالة صحيحة ولا تمنع الإضافة أو إرسال الطلب.
      expect(controller.hasSingleSupplier, isFalse);

      expect(
        controller.totalPrice,
        firstSupplierProduct.price + differentSupplierProduct.price,
      );
    });
    test('allows another supplier after clearing the cart', () {
      final CartController controller = CartController();

      controller.addProduct(firstSupplierProduct);
      controller.clear();

      final CartAddResult result = controller.addProduct(
        differentSupplierProduct,
      );

      expect(result, CartAddResult.added);
      expect(controller.items, hasLength(1));
      expect(controller.supplierId, 'supplier-2');
      expect(controller.supplierName, 'متجر التقنية');
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/dto/products_dto.dart';

void main() {
  group('ProductDto.fromJson', () {
    test('parses API values and supported snake_case keys', () {
      final dto = ProductDto.fromJson({
        'id': 7,
        'name': 'شاحن سريع',
        'price': '4500.5',
        'image_url': 'https://example.com/product.png',
        'category': 'شواحن',
        'brand': 'طلبيتك',
        'is_available': 1,
        'description': 'ضمان سنة',
        'colors': ['أسود', 'أبيض'],
        'stock_quantity': '3',
        'discount': 5,
        'rating': '4.8',
      });

      expect(dto.id, '7');
      expect(dto.price, 4500.5);
      expect(dto.imageUrl, 'https://example.com/product.png');
      expect(dto.isAvailable, isTrue);
      expect(dto.colors, ['أسود', 'أبيض']);
      expect(dto.quantity, 3);
      expect(dto.discount, 5);
      expect(dto.rating, 4.8);
    });

    test('rejects a payload without a valid id or price', () {
      expect(
        () => ProductDto.fromJson({'name': 'منتج', 'price': 100}),
        throwsFormatException,
      );

      expect(
        () => ProductDto.fromJson({
          'id': 'product-1',
          'name': 'منتج',
          'price': 'invalid',
        }),
        throwsFormatException,
      );
    });
  });
}

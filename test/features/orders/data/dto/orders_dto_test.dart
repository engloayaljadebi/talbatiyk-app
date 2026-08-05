import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/orders/data/dto/orders_dto.dart';

void main() {
  group('OrderDto', () {
    test('reads nested supplier data', () {
      final OrderDto dto = OrderDto.fromJson({
        'id': 'order-1',
        'status': 'pending',
        'created_at': '2026-08-05T03:00:00Z',
        'supplier': {'id': 'supplier-1', 'name': 'مؤسسة الأمل'},
        'items': [
          {
            'product_id': 'product-1',
            'product_name': 'شاحن سريع',
            'unit_price': 4500,
            'quantity': 2,
            'image_url': '',
          },
        ],
      });

      expect(dto.id, 'order-1');
      expect(dto.status, 'pending');
      expect(dto.supplier, isNotNull);
      expect(dto.supplier?.id, 'supplier-1');
      expect(dto.supplier?.name, 'مؤسسة الأمل');
      expect(dto.items, hasLength(1));
      expect(dto.items.single.quantity, 2);
    });

    test('reads supplier data from flat API fields', () {
      final OrderDto dto = OrderDto.fromJson({
        'id': 'order-2',
        'status': 'confirmed',
        'createdAt': '2026-08-05T04:00:00Z',
        'vendor_id': 'supplier-2',
        'vendor_name': 'متجر التقنية',
        'order_items': [
          {
            'productId': 'product-2',
            'productName': 'سماعة لاسلكية',
            'unitPrice': '8000',
            'quantity': 1,
          },
        ],
      });

      expect(dto.supplier, isNotNull);
      expect(dto.supplier?.id, 'supplier-2');
      expect(dto.supplier?.name, 'متجر التقنية');
      expect(dto.items.single.unitPrice, 8000);
    });

    test('keeps supplier null when data is absent', () {
      final OrderDto dto = OrderDto.fromJson({
        'id': 'order-3',
        'status': 'pending',
        'created_at': '2026-08-05T05:00:00Z',
        'items': [
          {
            'product_id': 'product-3',
            'product_name': 'هاتف ذكي',
            'unit_price': 120000,
            'quantity': 1,
          },
        ],
      });

      expect(dto.supplier, isNull);
    });
  });
}

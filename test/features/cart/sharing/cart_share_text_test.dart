import 'package:flutter_test/flutter_test.dart';
import 'package:talbytk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbytk/features/cart/sharing/cart_share_data.dart';
import 'package:talbytk/features/cart/sharing/cart_share_text.dart';

void main() {
  final item = CartItemEntity.manual(
    id: 'manual-private-id',
    name: 'شاي Green Tea',
    unitPrice: 125.5,
    quantity: 3,
    unit: 'كرتون',
    note: 'السعر المكتوب 9876',
  );

  test('hidden prices and excluded notes are absent from the final text', () {
    final data = CartShareData.fromItems([
      item,
    ], options: CartShareOptions(excludedNoteIndexes: [0]));

    expect(
      buildCartShareText(data),
      'اصناف الطلبية\n\n1. شاي Green Tea\nالكمية: 3 كرتون',
    );
  });

  test('visible prices include unit price, line total, and cart total', () {
    final data = CartShareData.fromItems([
      item,
    ], options: CartShareOptions(showPrices: true));

    expect(
      buildCartShareText(data),
      'اصناف الطلبية\n\n'
      '1. شاي Green Tea\n'
      'الكمية: 3 كرتون\n'
      'ملاحظة: السعر المكتوب 9876\n'
      'سعر الوحدة: 125.50 ر.ي\n'
      'إجمالي الصنف: 376.50 ر.ي\n\n'
      'إجمالي السلة: 376.50 ر.ي',
    );
  });
}

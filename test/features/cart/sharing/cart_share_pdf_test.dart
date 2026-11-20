import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/sharing/cart_share_data.dart';
import 'package:talbatiyk/features/cart/sharing/cart_share_pdf.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final item = CartItemEntity.manual(
    id: 'tea',
    name: 'شاي Green Tea',
    unitPrice: 12.5,
    quantity: 3,
    unit: 'كرتون',
    note: 'تعبئة 24 حبة',
  );

  for (final showPrices in [false, true]) {
    test('generates the cart table with showPrices=$showPrices', () async {
      final data = CartShareData.fromItems([
        item,
      ], options: CartShareOptions(showPrices: showPrices));

      final bytes = await buildCartSharePdf(data);

      expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
      expect(bytes.length, greaterThan(5));
    });
  }

  test('generates a document for a cart spanning multiple pages', () async {
    final data = CartShareData.fromItems(
      List.filled(100, item),
      options: CartShareOptions(),
    );

    final bytes = await buildCartSharePdf(data);

    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    final source = latin1.decode(bytes);
    final pageObjects = RegExp(r'/Type\s*/Page\b').allMatches(source);
    expect(pageObjects.length, greaterThan(1));
  });
}

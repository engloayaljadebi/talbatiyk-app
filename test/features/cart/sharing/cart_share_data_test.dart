import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/sharing/cart_share_data.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  const catalog = CartItemEntity(
    product: ProductEntity(
      id: 'catalog-1',
      name: 'شاي',
      price: 125,
      imageUrl: '',
      category: '',
      brand: '',
      isAvailable: true,
    ),
    quantity: 2,
  );

  final manual = CartItemEntity.manual(
    id: 'manual-1',
    name: 'أكياس',
    unitPrice: 10.5,
    quantity: 3,
    unit: 'كرتون',
    note: 'سعر الشراء 900',
  );

  test('prices are absent by default for both item kinds', () {
    final share = CartShareData.fromItems([
      catalog,
      manual,
    ], options: CartShareOptions());

    expect(share.items.map((item) => item.name), ['شاي', 'أكياس']);
    expect(share.items.map((item) => item.quantity), [2, 3]);
    expect(share.items.last.unit, 'كرتون');
    expect(share.items.every((item) => item.price == null), isTrue);
    expect(share.totalPrice, isNull);
  });

  test('enabled pricing includes unit, line, and cart totals', () {
    final share = CartShareData.fromItems([
      catalog,
      manual,
    ], options: CartShareOptions(showPrices: true));

    expect(share.items.first.price?.unitPrice, 125);
    expect(share.items.first.price?.lineTotal, 250);
    expect(share.items.last.price?.unitPrice, 10.5);
    expect(share.items.last.price?.lineTotal, 31.5);
    expect(share.totalPrice, 281.5);
  });

  test('omitting a note affects only the exported snapshot', () {
    final snapshot = [catalog, manual];
    final share = CartShareData.fromItems(
      snapshot,
      options: CartShareOptions(excludedNoteIndexes: [1]),
    );
    snapshot.clear();

    expect(share.items, hasLength(2));
    expect(share.items.last.note, isNull);
    expect(manual.note, 'سعر الشراء 900');
  });
}

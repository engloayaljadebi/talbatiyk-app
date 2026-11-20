import '../domain/entities/cart_item_entity.dart';

class CartShareOptions {
  CartShareOptions({
    this.showPrices = false,
    Iterable<int> excludedNoteIndexes = const [],
  }) : excludedNoteIndexes = Set<int>.unmodifiable(excludedNoteIndexes);

  final bool showPrices;

  /// Zero-based positions in the fixed cart snapshot shown in the preview.
  final Set<int> excludedNoteIndexes;
}

class CartShareData {
  CartShareData._(List<CartShareItem> items, this.totalPrice)
    : items = List<CartShareItem>.unmodifiable(items);

  factory CartShareData.fromItems(
    Iterable<CartItemEntity> snapshot, {
    required CartShareOptions options,
  }) {
    final items = <CartShareItem>[];
    var total = 0.0;

    for (final item in snapshot) {
      final price = options.showPrices
          ? CartSharePrice(
              unitPrice: item.unitPrice,
              lineTotal: item.totalPrice,
            )
          : null;
      final note = options.excludedNoteIndexes.contains(items.length)
          ? null
          : item.note;

      items.add(
        CartShareItem(
          name: item.product.name,
          quantity: item.quantity,
          unit: item.unit,
          note: note,
          price: price,
        ),
      );

      if (price != null) {
        total += price.lineTotal;
      }
    }

    return CartShareData._(items, options.showPrices ? total : null);
  }

  final List<CartShareItem> items;
  final double? totalPrice;
}

class CartShareItem {
  const CartShareItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.note,
    required this.price,
  });

  final String name;
  final int quantity;
  final String? unit;
  final String? note;
  final CartSharePrice? price;
}

class CartSharePrice {
  const CartSharePrice({required this.unitPrice, required this.lineTotal});

  final double unitPrice;
  final double lineTotal;
}

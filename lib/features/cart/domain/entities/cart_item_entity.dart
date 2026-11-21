import 'package:talbytk/features/products/domain/entities/products_entity.dart';

const Object _cartItemUnset = Object();

enum CartItemKind { catalog, manual }

class CartItemEntity {
  const CartItemEntity({
    required this.product,
    required this.quantity,
    this.kind = CartItemKind.catalog,
    this.manualId,
    this.unit,
    this.note,
  }) : assert(quantity > 0),
       assert(kind != CartItemKind.manual || manualId != null);

  final ProductEntity product;

  final int quantity;

  final CartItemKind kind;

  /// Stable local identity for a manually entered cart item.
  final String? manualId;

  final String? unit;

  final String? note;

  bool get isManual => kind == CartItemKind.manual;

  String get id => isManual ? (manualId ?? product.id) : product.id;

  String? get catalogProductId => isManual ? null : product.id;

  /// The single source of unit price for catalog and manual items.
  double get unitPrice => product.price;

  /// Calculated line total.
  double get totalPrice => product.price * quantity;

  factory CartItemEntity.manual({
    required String id,
    required String name,
    required double unitPrice,
    required int quantity,
    String? unit,
    String? note,
  }) {
    final normalizedId = id.trim();
    final normalizedName = name.trim();
    final normalizedUnit = unit?.trim();
    final normalizedNote = note?.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(id, 'id', 'Manual item ID is required.');
    }

    if (normalizedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Item name is required.');
    }

    if (!unitPrice.isFinite || unitPrice < 0) {
      throw ArgumentError.value(
        unitPrice,
        'unitPrice',
        'Unit price must be a valid non-negative number.',
      );
    }

    if (quantity < 1) {
      throw ArgumentError.value(
        quantity,
        'quantity',
        'Quantity must be at least one.',
      );
    }

    return CartItemEntity(
      product: ProductEntity(
        id: normalizedId,
        name: normalizedName,
        price: unitPrice,
        imageUrl: '',
        category: '',
        brand: '',
        isAvailable: true,
        supplierId: '',
        supplierName: '',
        description: '',
      ),
      quantity: quantity,
      kind: CartItemKind.manual,
      manualId: normalizedId,
      unit: normalizedUnit == null || normalizedUnit.isEmpty
          ? null
          : normalizedUnit,
      note: normalizedNote == null || normalizedNote.isEmpty
          ? null
          : normalizedNote,
    );
  }

  CartItemEntity copyWith({
    ProductEntity? product,
    int? quantity,
    CartItemKind? kind,
    String? manualId,
    Object? unit = _cartItemUnset,
    Object? note = _cartItemUnset,
  }) {
    return CartItemEntity(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      kind: kind ?? this.kind,
      manualId: manualId ?? this.manualId,
      unit: identical(unit, _cartItemUnset) ? this.unit : unit as String?,
      note: identical(note, _cartItemUnset) ? this.note : note as String?,
    );
  }
}

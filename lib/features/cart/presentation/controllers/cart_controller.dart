import 'package:flutter/foundation.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

class CartController extends ChangeNotifier {
  final Map<String, CartItemEntity> _items = {};

  List<CartItemEntity> get items => List.unmodifiable(_items.values);

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  int get totalQuantity {
    return _items.values.fold(0, (total, item) => total + item.quantity);
  }

  double get totalPrice {
    return _items.values.fold(0, (total, item) => total + item.totalPrice);
  }

  int quantityOf(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  void addProduct(ProductEntity product) {
    if (!product.isAvailable) return;

    final currentItem = _items[product.id];

    if (currentItem == null) {
      _items[product.id] = CartItemEntity(product: product, quantity: 1);
    } else {
      _items[product.id] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    }

    notifyListeners();
  }

  void decreaseProduct(String productId) {
    final currentItem = _items[productId];

    if (currentItem == null) return;

    if (currentItem.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = currentItem.copyWith(
        quantity: currentItem.quantity - 1,
      );
    }

    notifyListeners();
  }

  void removeProduct(String productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  void clear() {
    if (_items.isEmpty) return;

    _items.clear();
    notifyListeners();
  }
}

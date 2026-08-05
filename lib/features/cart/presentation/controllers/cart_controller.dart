import 'package:flutter/foundation.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

/// نتيجة محاولة إضافة منتج إلى السلة.
enum CartAddResult {
  /// تمت إضافة المنتج أو زيادة كميته.
  added,

  /// المنتج غير متوفر.
  unavailable,

  /// المنتج يتبع موردًا مختلفًا عن مورد منتجات السلة.
  differentSupplier,
}

/// المتحكم المسؤول عن إدارة سلة المنتجات.
///
/// قاعدة العمل الأساسية:
/// جميع المنتجات الموجودة في السلة يجب أن تتبع موردًا واحدًا،
/// لأن كل طلبية تُرسل إلى مورد واحد فقط.
class CartController extends ChangeNotifier {
  final Map<String, CartItemEntity> _items = {};

  /// عناصر السلة الحالية.
  List<CartItemEntity> get items {
    return List<CartItemEntity>.unmodifiable(_items.values);
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  /// أول منتج داخل السلة ويُستخدم لمعرفة المورد الحالي.
  ProductEntity? get _firstProduct {
    if (_items.isEmpty) {
      return null;
    }

    return _items.values.first.product;
  }

  /// معرّف مورد السلة الحالية.
  String get supplierId {
    return _firstProduct?.supplierId.trim() ?? '';
  }

  /// اسم مورد السلة الحالية.
  String get supplierName {
    return _firstProduct?.supplierName.trim() ?? '';
  }

  /// هل تحتوي السلة على منتجات من مورد واحد؟
  bool get hasSingleSupplier {
    final ProductEntity? firstProduct = _firstProduct;

    if (firstProduct == null) {
      return true;
    }

    return _items.values.every((CartItemEntity item) {
      return _isSameSupplier(firstProduct, item.product);
    });
  }

  int get totalQuantity {
    return _items.values.fold(0, (int total, CartItemEntity item) {
      return total + item.quantity;
    });
  }

  double get totalPrice {
    return _items.values.fold(0, (double total, CartItemEntity item) {
      return total + item.totalPrice;
    });
  }

  /// كمية منتج محدد داخل السلة.
  int quantityOf(String productId) {
    return _items[productId]?.quantity ?? 0;
  }

  /// هل يمكن إضافة المنتج دون مخالفة مورد السلة؟
  bool canAddProduct(ProductEntity product) {
    final ProductEntity? firstProduct = _firstProduct;

    if (firstProduct == null) {
      return true;
    }

    return _isSameSupplier(firstProduct, product);
  }

  /// إضافة منتج أو زيادة كميته.
  CartAddResult addProduct(ProductEntity product) {
    if (!product.isAvailable) {
      return CartAddResult.unavailable;
    }

    if (!canAddProduct(product)) {
      return CartAddResult.differentSupplier;
    }

    final CartItemEntity? currentItem = _items[product.id];

    if (currentItem == null) {
      _items[product.id] = CartItemEntity(product: product, quantity: 1);
    } else {
      _items[product.id] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    }

    notifyListeners();
    return CartAddResult.added;
  }

  /// تقليل كمية منتج واحد.
  void decreaseProduct(String productId) {
    final CartItemEntity? currentItem = _items[productId];

    if (currentItem == null) {
      return;
    }

    if (currentItem.quantity <= 1) {
      _items.remove(productId);
    } else {
      _items[productId] = currentItem.copyWith(
        quantity: currentItem.quantity - 1,
      );
    }

    notifyListeners();
  }

  /// حذف منتج كاملًا من السلة.
  void removeProduct(String productId) {
    if (_items.remove(productId) != null) {
      notifyListeners();
    }
  }

  /// حذف جميع منتجات السلة.
  void clear() {
    if (_items.isEmpty) {
      return;
    }

    _items.clear();
    notifyListeners();
  }

  /// مقارنة موردي منتجين.
  ///
  /// نعتمد على المعرّف عندما يكون موجودًا لدى المنتجين،
  /// وإلا نقارن الاسم لدعم البيانات المحلية والقديمة.
  bool _isSameSupplier(ProductEntity first, ProductEntity second) {
    final String firstId = first.supplierId.trim();
    final String secondId = second.supplierId.trim();

    if (firstId.isNotEmpty && secondId.isNotEmpty) {
      return firstId == secondId;
    }

    final String firstName = first.supplierName.trim().toLowerCase();
    final String secondName = second.supplierName.trim().toLowerCase();

    if (firstName.isNotEmpty && secondName.isNotEmpty) {
      return firstName == secondName;
    }

    // دعم المنتجات القديمة التي لا تحتوي بيانات مورد.
    return firstId.isEmpty &&
        secondId.isEmpty &&
        firstName.isEmpty &&
        secondName.isEmpty;
  }
}

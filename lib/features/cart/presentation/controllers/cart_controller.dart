import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:talbatiyk/features/cart/data/datasources/local/cart_local_datasource.dart';
import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

/// نتيجة محاولة إضافة منتج إلى السلة.
enum CartAddResult {
  /// تمت إضافة المنتج أو زيادة كميته.
  added,

  /// المنتج غير متوفر ولا يمكن إضافته.
  unavailable,

  /// قيمة قديمة محفوظة للتوافق مع الـPublic API الحالي.
  ///
  /// السلة أصبحت Multi-Supplier ولا يتم إرجاع هذه النتيجة عند اختلاف المورد.
  differentSupplier,

  /// The active cart is temporarily locked during a cart switch.
  busy,
}

/// Result of switching the active cart.
enum CartSwitchResult { switched, alreadyActive, unavailable, busy, failed }

/// يدير حالة سلة العميل ويحفظها محليًا في Drift.
///
/// قواعد العمل:
/// - السلة تدعم منتجات من مورد واحد أو عدة موردين.
/// - كل عنصر يحتفظ بهوية المورد الخاصة به.
/// - شرط Follow يتم تطبيقه قبل الوصول إلى CartController.
/// - هذا Controller لا ينفذ Network calls ولا Supplier Follow logic.
/// - أي mutation ناجح يُحفظ محليًا حتى تبقى السلة بعد إغلاق التطبيق.
class CartController extends ChangeNotifier {
  CartController({CartLocalDataSource? localDataSource})
    : this._(localDataSource);

  CartController._(this._localDataSource) {
    _cartIdFuture = _resolveCartId();
    _ready = _restore();
  }

  final CartLocalDataSource? _localDataSource;

  late final Future<String?> _cartIdFuture;

  final Map<String, CartItemEntity> _items = {};

  late final Future<void> _ready;

  /// تسلسل عمليات الكتابة يمنع أن تتجاوز عملية حفظ أحدث عملية أقدم.
  Future<void> _persistenceQueue = Future<void>.value();

  Object? _lastPersistenceError;

  StackTrace? _lastPersistenceStackTrace;

  /// True after the initial Drift restore has completed.
  bool _restoreCompleted = false;

  /// Mutations accepted before restore completes are replayed over the
  /// persisted snapshot to prevent early mutations from discarding stored data.
  final List<void Function(Map<String, CartItemEntity>)>
  _pendingRestoreMutations = [];

  /// معرّف السلة التي يعمل عليها هذا Controller.
  String? _activeCartId;

  bool _isSwitching = false;

  /// يكتمل بعد انتهاء استعادة السلة من Drift.
  Future<void> get ready => _ready;

  /// معرّف السلة المرتبطة بهذا Controller.
  String? get activeCartId => _activeCartId;

  /// True while the controller is changing its active cart.
  bool get isSwitching => _isSwitching;

  /// ينتظر اكتمال جميع عمليات الحفظ المحلية المعلقة.
  ///
  /// مفيد خصوصًا في الاختبارات وعند الحاجة للتأكد من اكتمال persistence.
  Future<void> flushPersistence() async {
    await _ready;
    await _persistenceQueue;

    final error = _lastPersistenceError;

    if (error != null) {
      Error.throwWithStackTrace(
        error,
        _lastPersistenceStackTrace ?? StackTrace.current,
      );
    }
  }

  /// Creates a new cart, persists the previous cart, and activates the new one.
  Future<({String id, String name})> createCartAndActivate(String name) async {
    final localDataSource = _localDataSource;

    if (localDataSource == null) {
      throw StateError('Cannot create a cart without authenticated ownership.');
    }

    if (_isSwitching) {
      throw StateError('A cart transition is already in progress.');
    }

    _isSwitching = true;
    notifyListeners();

    try {
      await _ready;
      await flushPersistence();

      final createdCart = await localDataSource.createCartAndActivate(name);

      _items.clear();
      _activeCartId = createdCart.id;

      return createdCart;
    } finally {
      _isSwitching = false;
      notifyListeners();
    }
  }

  /// Switches to another cart without mixing pending writes or cart contents.
  Future<CartSwitchResult> switchToCart(String cartId) async {
    final localDataSource = _localDataSource;
    final normalizedCartId = cartId.trim();

    if (localDataSource == null || normalizedCartId.isEmpty) {
      return CartSwitchResult.unavailable;
    }

    if (_isSwitching) {
      return CartSwitchResult.busy;
    }

    _isSwitching = true;
    notifyListeners();

    try {
      // Complete initial restoration before evaluating the current cart.
      await _ready;

      if (normalizedCartId == _activeCartId) {
        return CartSwitchResult.alreadyActive;
      }

      // All pending writes must finish against the old cart first.
      await flushPersistence();

      // Verify that the destination belongs to the authenticated account.
      final ownedCart = await localDataSource.getOwnedCart(normalizedCartId);

      if (ownedCart == null) {
        return CartSwitchResult.unavailable;
      }

      // Load destination contents before changing the saved selection.
      final restoredItems = await localDataSource.getItemsForCart(ownedCart.id);

      // Persist the new selection only after successful validation and read.
      await localDataSource.setActiveCart(ownedCart.id);

      // Commit the in-memory transition after all previous operations succeed.
      _items
        ..clear()
        ..addEntries(
          restoredItems.map((item) => MapEntry(item.product.id, item)),
        );

      _activeCartId = ownedCart.id;

      return CartSwitchResult.switched;
    } catch (_) {
      // Keep the previous in-memory cart unchanged on failure.
      return CartSwitchResult.failed;
    } finally {
      _isSwitching = false;
      notifyListeners();
    }
  }

  /// Snapshot غير قابل للتعديل لعناصر السلة الحالية.
  List<CartItemEntity> get items {
    return List<CartItemEntity>.unmodifiable(_items.values);
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  /// أول منتج في السلة.
  ///
  /// يستخدم فقط لدعم getters القديمة ولا يمثل المورد الوحيد للطلب.
  ProductEntity? get _firstProduct {
    if (_items.isEmpty) {
      return null;
    }

    return _items.values.first.product;
  }

  /// معرّف مورد أول عنصر في السلة.
  ///
  /// Getter قديم للتوافق فقط. لا يجب استخدامه باعتباره مورد الطلب الوحيد
  /// لأن السلة والطلبات تدعمان Multi-Supplier.
  String get supplierId {
    return _firstProduct?.supplierId.trim() ?? '';
  }

  /// اسم مورد أول عنصر في السلة.
  ///
  /// Getter قديم للتوافق فقط ولا يعني أن جميع العناصر تتبع نفس المورد.
  String get supplierName {
    return _firstProduct?.supplierName.trim() ?? '';
  }

  /// يفيد في التشخيص والعرض فقط.
  ///
  /// false حالة صحيحة وطبيعية في Multi-Supplier Cart ولا تمنع الإرسال.
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

  /// يحدد ما إذا كان المنتج صالحًا للإضافة من منظور السلة.
  ///
  /// اختلاف المورد ليس مانعًا. شرط Follow مسؤولية التدفق السابق للإضافة.
  bool canAddProduct(ProductEntity product) {
    return product.isAvailable;
  }

  /// يحل هوية السلة مرة واحدة عند تهيئة Controller.
  Future<String?> _resolveCartId() async {
    final localDataSource = _localDataSource;

    if (localDataSource == null) {
      return null;
    }

    final cartId = await localDataSource.resolveCurrentCartId();

    _activeCartId = cartId;

    return cartId;
  }

  /// Restores persisted items, then replays mutations accepted during loading.
  Future<void> _restore() async {
    final localDataSource = _localDataSource;

    if (localDataSource == null) {
      _restoreCompleted = true;
      _pendingRestoreMutations.clear();
      return;
    }

    final cartId = await _cartIdFuture;

    if (cartId == null) {
      _restoreCompleted = true;
      _pendingRestoreMutations.clear();
      return;
    }

    final restoredItems = await localDataSource.getItemsForCart(cartId);

    // Start with the persisted state.
    _items
      ..clear()
      ..addEntries(
        restoredItems.map((item) => MapEntry(item.product.id, item)),
      );

    // Replay every mutation accepted while the database read was pending.
    final hadPendingMutations = _pendingRestoreMutations.isNotEmpty;

    for (final mutation in _pendingRestoreMutations) {
      mutation(_items);
    }

    _pendingRestoreMutations.clear();
    _restoreCompleted = true;

    if (restoredItems.isNotEmpty || hadPendingMutations) {
      notifyListeners();
    }
  }

  /// Records a mutation for replay when the initial restore is still pending.
  void _recordMutationDuringRestore(
    void Function(Map<String, CartItemEntity>) mutation,
  ) {
    if (!_restoreCompleted) {
      _pendingRestoreMutations.add(mutation);
    }
  }

  /// Commits a successful mutation and schedules local persistence.
  void _commitMutation() {
    notifyListeners();
    _schedulePersistence();
  }

  /// Saves snapshots sequentially after the initial restore has completed.
  void _schedulePersistence() {
    final localDataSource = _localDataSource;

    if (localDataSource == null) {
      return;
    }

    // Capture the destination at mutation time, not when the queued write runs.
    final scheduledCartId = _activeCartId;

    final cartIdFuture = scheduledCartId == null
        ? _cartIdFuture
        : Future<String?>.value(scheduledCartId);

    final persistenceOperation = _persistenceQueue.then((_) async {
      await _ready;

      final cartId = await cartIdFuture;

      if (cartId == null) {
        return;
      }

      // Capture the snapshot only after restoration and mutation replay.
      final snapshot = List<CartItemEntity>.unmodifiable(_items.values);

      await localDataSource.replaceItemsForCart(cartId, snapshot);
    });

    // Preserve queue continuity while exposing the last write failure.
    _persistenceQueue = persistenceOperation.then<void>(
      (_) {
        _lastPersistenceError = null;
        _lastPersistenceStackTrace = null;
      },
      onError: (Object error, StackTrace stackTrace) {
        _lastPersistenceError = error;
        _lastPersistenceStackTrace = stackTrace;

        FlutterError.reportError(
          FlutterErrorDetails(
            exception: error,
            stack: stackTrace,
            library: 'Talbatiyk Cart persistence',
          ),
        );
      },
    );

    unawaited(_persistenceQueue);
  }

  /// يضيف منتجًا جديدًا أو يزيد كميته.
  ///
  /// Multi-Supplier مسموح. التحقق من Follow يجب أن يكون قد تم قبل استدعاء
  /// هذه الدالة من Product Details flow.
  CartAddResult addProduct(ProductEntity product) {
    if (_isSwitching) {
      return CartAddResult.busy;
    }

    if (!canAddProduct(product)) {
      return CartAddResult.unavailable;
    }

    _applyAddProduct(_items, product);

    _recordMutationDuringRestore((items) => _applyAddProduct(items, product));

    _commitMutation();

    return CartAddResult.added;
  }

  /// Decreases a product, preserving the operation if restore is pending.
  void decreaseProduct(String productId) {
    if (_isSwitching) {
      return;
    }
    final isRestoring = !_restoreCompleted;

    if (!isRestoring && !_items.containsKey(productId)) {
      return;
    }

    _applyDecreaseProduct(_items, productId);

    _recordMutationDuringRestore(
      (items) => _applyDecreaseProduct(items, productId),
    );

    _commitMutation();
  }

  /// Removes one product, including from the pending restored state.
  void removeProduct(String productId) {
    if (_isSwitching) {
      return;
    }
    final isRestoring = !_restoreCompleted;

    if (!isRestoring && !_items.containsKey(productId)) {
      return;
    }

    _items.remove(productId);

    _recordMutationDuringRestore((items) => items.remove(productId));

    _commitMutation();
  }

  /// Removes a group of products in one mutation.
  void removeProducts(Iterable<String> productIds) {
    if (_isSwitching) {
      return;
    }
    final ids = productIds.toSet().toList(growable: false);

    if (ids.isEmpty) {
      return;
    }

    var changed = false;

    for (final productId in ids) {
      if (_items.remove(productId) != null) {
        changed = true;
      }
    }

    if (!changed && _restoreCompleted) {
      return;
    }

    _recordMutationDuringRestore((items) {
      for (final productId in ids) {
        items.remove(productId);
      }
    });

    _commitMutation();
  }

  /// Clears the current and pending restored cart state.
  void clear() {
    if (_isSwitching) {
      return;
    }
    if (_items.isEmpty && _restoreCompleted) {
      return;
    }

    _items.clear();

    _recordMutationDuringRestore((items) => items.clear());

    _commitMutation();
  }

  void _applyAddProduct(
    Map<String, CartItemEntity> items,
    ProductEntity product,
  ) {
    final currentItem = items[product.id];

    if (currentItem == null) {
      items[product.id] = CartItemEntity(product: product, quantity: 1);
    } else {
      items[product.id] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    }
  }

  void _applyDecreaseProduct(
    Map<String, CartItemEntity> items,
    String productId,
  ) {
    final currentItem = items[productId];

    if (currentItem == null) {
      return;
    }

    if (currentItem.quantity <= 1) {
      items.remove(productId);
    } else {
      items[productId] = currentItem.copyWith(
        quantity: currentItem.quantity - 1,
      );
    }
  }

  /// يقارن الموردين لأغراض التشخيص فقط.
  ///
  /// هذه الدالة لا تستخدم لمنع إضافة منتج من مورد مختلف.
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

    // دعم البيانات القديمة التي لا تحتوي على هوية مورد.
    return firstId.isEmpty &&
        secondId.isEmpty &&
        firstName.isEmpty &&
        secondName.isEmpty;
  }
}

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
}

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
    _ready = _restore();
  }

  final CartLocalDataSource? _localDataSource;

  final Map<String, CartItemEntity> _items = {};

  late final Future<void> _ready;

  /// تسلسل عمليات الكتابة يمنع أن تتجاوز عملية حفظ أحدث عملية أقدم.
  Future<void> _persistenceQueue = Future<void>.value();

  /// يستخدم لمنع Restore قديم من الكتابة فوق mutation حدث أثناء التحميل.
  int _mutationRevision = 0;

  /// يكتمل بعد انتهاء استعادة السلة من Drift.
  Future<void> get ready => _ready;

  /// ينتظر اكتمال جميع عمليات الحفظ المحلية المعلقة.
  ///
  /// مفيد خصوصًا في الاختبارات وعند الحاجة للتأكد من اكتمال persistence.
  Future<void> flushPersistence() async {
    await _ready;
    await _persistenceQueue;
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

  /// يستعيد السلة المحفوظة من Drift عند بدء التطبيق.
  Future<void> _restore() async {
    final localDataSource = _localDataSource;

    if (localDataSource == null) {
      return;
    }

    final revisionAtStart = _mutationRevision;
    final restoredItems = await localDataSource.getItems();

    // إذا حدث تعديل أثناء القراءة من Drift، تبقى الحالة الحية هي الأحدث
    // ولا نسمح لـSnapshot قديم باستبدالها.
    if (revisionAtStart != _mutationRevision) {
      return;
    }

    _items
      ..clear()
      ..addEntries(
        restoredItems.map((item) => MapEntry(item.product.id, item)),
      );

    if (restoredItems.isNotEmpty) {
      notifyListeners();
    }
  }

  /// يسجل Mutation ناجحًا ويحدث UI ويجدول حفظ Snapshot الجديدة.
  void _commitMutation() {
    _mutationRevision += 1;
    notifyListeners();
    _schedulePersistence();
  }

  /// يحفظ Snapshot السلة بالتسلسل لمنع سباقات الكتابة.
  void _schedulePersistence() {
    final localDataSource = _localDataSource;

    if (localDataSource == null) {
      return;
    }

    final snapshot = List<CartItemEntity>.unmodifiable(_items.values);

    final persistenceOperation = _persistenceQueue.then((_) async {
      await _ready;
      await localDataSource.replaceItems(snapshot);
    });

    // فشل حفظ واحد يجب ألا يكسر Queue المستقبلية أو يتسبب في
    // Unhandled asynchronous error، لذلك نسجل الخطأ ثم نسمح باستمرارها.
    _persistenceQueue = persistenceOperation.catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'Talbatiyk Cart persistence',
        ),
      );
    });

    unawaited(_persistenceQueue);
  }

  /// يضيف منتجًا جديدًا أو يزيد كميته.
  ///
  /// Multi-Supplier مسموح. التحقق من Follow يجب أن يكون قد تم قبل استدعاء
  /// هذه الدالة من Product Details flow.
  CartAddResult addProduct(ProductEntity product) {
    if (!canAddProduct(product)) {
      return CartAddResult.unavailable;
    }

    final CartItemEntity? currentItem = _items[product.id];

    if (currentItem == null) {
      _items[product.id] = CartItemEntity(product: product, quantity: 1);
    } else {
      _items[product.id] = currentItem.copyWith(
        quantity: currentItem.quantity + 1,
      );
    }

    _commitMutation();

    return CartAddResult.added;
  }

  /// يقلل كمية المنتج، ويحذفه عندما تصل الكمية إلى الصفر.
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

    _commitMutation();
  }

  /// يحذف منتجًا كاملًا من السلة.
  void removeProduct(String productId) {
    if (_items.remove(productId) != null) {
      _commitMutation();
    }
  }

  /// يحذف مجموعة منتجات بعد نجاح إرسال الجزء المختار من السلة.
  ///
  /// لا نمسح بقية الموردين لأن المستخدم قد يختار إرسال الطلب
  /// إلى مورد واحد أو مجموعة موردين فقط.
  void removeProducts(Iterable<String> productIds) {
    var changed = false;

    for (final productId in productIds) {
      if (_items.remove(productId) != null) {
        changed = true;
      }
    }

    if (changed) {
      _commitMutation();
    }
  }

  /// يحذف مجموعة منتجات بعد نجاح إرسال الجزء الخاص بها من السلة.
  ///
  /// نستخدم Mutation واحدة حتى نحفظ Snapshot واحدة في Drift بدل كتابة
  /// قاعدة البيانات مرة لكل عنصر.

  /// يمسح السلة كاملة ويحفظ الحالة الفارغة في Drift.
  void clear() {
    if (_items.isEmpty) {
      return;
    }

    _items.clear();
    _commitMutation();
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

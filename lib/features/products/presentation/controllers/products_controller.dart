import 'package:flutter/foundation.dart';

import '../../domain/entities/products_entity.dart';
import '../../domain/usecases/products_usecase.dart';
import '../state/products_state.dart';

class ProductsController extends ChangeNotifier {
  ProductsController(
    this._useCase, {
    bool autoLoad = true,
    this.syncPendingMutations,
  }) {
    if (autoLoad) loadProducts();
  }

  final ProductsUseCase _useCase;

  final Future<void> Function()? syncPendingMutations;

  List<ProductEntity> _allProducts = [];

  /// Snapshot of loaded discovery products, independent of active UI filters.
  /// This is NOT the complete server catalog when the API is paginated.
  List<ProductEntity> get loadedDiscoveryProducts =>
      List<ProductEntity>.unmodifiable(_allProducts);

  ProductsState state = const ProductsState();

  List<String> get categories {
    final values = _allProducts
        .map((product) => product.category)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();

    values.sort();
    return values;
  }

  List<String> get brands {
    final values = _allProducts
        .map((product) => product.brand)
        .where((value) => value.trim().isNotEmpty)
        .toSet()
        .toList();

    values.sort();
    return values;
  }

  double get minimumPrice {
    if (_allProducts.isEmpty) return 0;

    return _allProducts
        .map((product) => product.price)
        .reduce((first, second) => first < second ? first : second);
  }

  double get maximumPrice {
    if (_allProducts.isEmpty) return 0;

    return _allProducts
        .map((product) => product.price)
        .reduce((first, second) => first > second ? first : second);
  }

  bool get hasActiveFilters {
    return state.selectedCategory.isNotEmpty ||
        state.selectedBrand.isNotEmpty ||
        state.availability != ProductAvailabilityFilter.all ||
        state.minPrice != null ||
        state.maxPrice != null;
  }

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    notifyListeners();

    try {
      _allProducts = await _useCase.getProducts();

      state = state.copyWith(isLoading: false, clearErrorMessage: true);

      _applyCurrentFilters();
    } catch (_) {
      _allProducts = [];

      state = state.copyWith(
        isLoading: false,
        products: const [],
        errorMessage: 'تعذر تحميل المنتجات، حاول مرة أخرى',
      );

      notifyListeners();
    }
  }

  /// يحفظ منتجًا جديدًا محليًا ثم يعيد تحميل قائمة المنتجات.
  ///
  /// ينشئ المنتج عبر مصدر الإنشاء المحدد في المستودع.
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final createdProduct = await _useCase.createProduct(product);

    /// إعادة التحميل تجعل المنتج الجديد يظهر فورًا في الواجهة.
    await loadProducts();

    return createdProduct;
  }

  /// يحدّث المنتج محليًا ثم يعيد تحميل القائمة.
  ///
  /// سيظهر التعديل مباشرة حتى عندما يكون الجهاز بدون إنترنت.
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    final updatedProduct = await _useCase.updateProduct(product);

    await _syncPendingMutationsSafely();
    await loadProducts();

    return updatedProduct;
  }

  Future<void> deleteProduct(String productId) async {
    await _useCase.deleteProduct(productId);

    await _syncPendingMutationsSafely();
    await loadProducts();
  }

  Future<void> _syncPendingMutationsSafely() async {
    final sync = syncPendingMutations;

    if (sync == null) {
      return;
    }

    try {
      await sync();
    } catch (error, stackTrace) {
      debugPrint(
        'Product mutation background sync failed: $error\n$stackTrace',
      );
    }
  }

  void search(String value) {
    state = state.copyWith(search: value);
    _applyCurrentFilters();
  }

  void applyFilters({
    required String category,
    required String brand,
    required ProductAvailabilityFilter availability,
    required double minPrice,
    required double maxPrice,
  }) {
    final shouldClearMin = _allProducts.isEmpty || minPrice <= minimumPrice;

    final shouldClearMax = _allProducts.isEmpty || maxPrice >= maximumPrice;

    state = state.copyWith(
      selectedCategory: category,
      selectedBrand: brand,
      availability: availability,
      minPrice: shouldClearMin ? null : minPrice,
      maxPrice: shouldClearMax ? null : maxPrice,
      clearMinPrice: shouldClearMin,
      clearMaxPrice: shouldClearMax,
    );

    _applyCurrentFilters();
  }

  void clearFilters() {
    state = state.copyWith(
      selectedCategory: '',
      selectedBrand: '',
      availability: ProductAvailabilityFilter.all,
      clearMinPrice: true,
      clearMaxPrice: true,
    );

    _applyCurrentFilters();
  }

  void clearAll() {
    state = state.copyWith(
      search: '',
      selectedCategory: '',
      selectedBrand: '',
      availability: ProductAvailabilityFilter.all,
      clearMinPrice: true,
      clearMaxPrice: true,
    );

    _applyCurrentFilters();
  }

  void changeView() {
    state = state.copyWith(isGrid: !state.isGrid);
    notifyListeners();
  }

  List<ProductEntity> get latestProducts {
    return List<ProductEntity>.unmodifiable(_allProducts.take(4));
  }

  void _applyCurrentFilters() {
    final query = state.search.trim().toLowerCase();

    final filteredProducts = _allProducts.where((product) {
      final matchesSearch =
          query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query) ||
          product.description.toLowerCase().contains(query);

      final matchesCategory =
          state.selectedCategory.isEmpty ||
          product.category == state.selectedCategory;

      final matchesBrand =
          state.selectedBrand.isEmpty || product.brand == state.selectedBrand;

      final matchesAvailability =
          state.availability == ProductAvailabilityFilter.all ||
          state.availability == ProductAvailabilityFilter.available &&
              product.isAvailable ||
          state.availability == ProductAvailabilityFilter.unavailable &&
              !product.isAvailable;

      final matchesMinimumPrice =
          state.minPrice == null || product.price >= state.minPrice!;

      final matchesMaximumPrice =
          state.maxPrice == null || product.price <= state.maxPrice!;

      return matchesSearch &&
          matchesCategory &&
          matchesBrand &&
          matchesAvailability &&
          matchesMinimumPrice &&
          matchesMaximumPrice;
    }).toList();

    state = state.copyWith(
      products: List<ProductEntity>.unmodifiable(filteredProducts),
    );

    notifyListeners();
  }
}

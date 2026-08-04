import '../../domain/entities/products_entity.dart';

enum ProductAvailabilityFilter { all, available, unavailable }

class ProductsState {
  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isGrid = false,
    this.selectedCategory = '',
    this.selectedBrand = '',
    this.availability = ProductAvailabilityFilter.all,
    this.minPrice,
    this.maxPrice,
    this.search = '',
    this.errorMessage,
  });

  final List<ProductEntity> products;
  final bool isLoading;
  final bool isGrid;

  final String selectedCategory;
  final String selectedBrand;
  final ProductAvailabilityFilter availability;

  final double? minPrice;
  final double? maxPrice;

  final String search;
  final String? errorMessage;

  bool get hasSearch => search.trim().isNotEmpty;

  ProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isGrid,
    String? selectedCategory,
    String? selectedBrand,
    ProductAvailabilityFilter? availability,
    double? minPrice,
    double? maxPrice,
    bool clearMinPrice = false,
    bool clearMaxPrice = false,
    String? search,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isGrid: isGrid ?? this.isGrid,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      availability: availability ?? this.availability,
      minPrice: clearMinPrice ? null : minPrice ?? this.minPrice,
      maxPrice: clearMaxPrice ? null : maxPrice ?? this.maxPrice,
      search: search ?? this.search,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }
}

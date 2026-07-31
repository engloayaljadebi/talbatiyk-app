import '../../domain/entities/products_entity.dart';

class ProductsState {
  const ProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isGrid = false,
    this.selectedCategory = '',
    this.search = '',
  });

  final List<ProductEntity> products;
  final bool isLoading;
  final bool isGrid;
  final String selectedCategory;
  final String search;

  ProductsState copyWith({
    List<ProductEntity>? products,
    bool? isLoading,
    bool? isGrid,
    String? selectedCategory,
    String? search,
  }) {
    return ProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isGrid: isGrid ?? this.isGrid,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      search: search ?? this.search,
    );
  }
}

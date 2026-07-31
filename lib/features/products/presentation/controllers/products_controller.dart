import 'package:flutter/foundation.dart';

import '../../data/datasources/local/products_local_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/usecases/products_usecase.dart';
import '../state/products_state.dart';

class ProductsController extends ChangeNotifier {
  ProductsController() {
    _useCase = ProductsUseCase(
      ProductsRepositoryImpl(ProductsLocalDataSource()),
    );

    loadProducts();
  }

  late final ProductsUseCase _useCase;

  ProductsState state = const ProductsState();

  Future<void> loadProducts() async {
    state = state.copyWith(isLoading: true);
    notifyListeners();

    final products = await _useCase.getProducts();

    state = state.copyWith(isLoading: false, products: products);

    notifyListeners();
  }

  Future<void> search(String value) async {
    final result = await _useCase.search(value);

    state = state.copyWith(search: value, products: result);

    notifyListeners();
  }

  void changeView() {
    state = state.copyWith(isGrid: !state.isGrid);

    notifyListeners();
  }
}

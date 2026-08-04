import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/products_local_datasource.dart';
import '../../data/datasources/products_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/products_usecase.dart';
import '../controllers/products_controller.dart';

/// Override this provider with a remote data source when the API client becomes
/// available. The UI and controller do not need to change.
final productsDataSourceProvider = Provider<ProductsDataSource>((ref) {
  return const ProductsLocalDataSource();
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productsDataSourceProvider));
});

final productsUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(ref.watch(productsRepositoryProvider));
});

final productsProvider = ChangeNotifierProvider<ProductsController>((ref) {
  return ProductsController(ref.watch(productsUseCaseProvider));
});

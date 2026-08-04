import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/local/orders_local_datasource.dart';
import '../../data/datasources/orders_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/usecases/orders_usecase.dart';
import '../controllers/orders_controller.dart';

/// Override this provider with a remote data source when the API is enabled.
final ordersDataSourceProvider = Provider<OrdersDataSource>((ref) {
  return OrdersLocalDataSource();
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(ref.watch(ordersDataSourceProvider));
});

final ordersUseCaseProvider = Provider<OrdersUseCase>((ref) {
  return OrdersUseCase(ref.watch(ordersRepositoryProvider));
});

final ordersProvider = ChangeNotifierProvider<OrdersController>((ref) {
  return OrdersController(ref.watch(ordersUseCaseProvider));
});

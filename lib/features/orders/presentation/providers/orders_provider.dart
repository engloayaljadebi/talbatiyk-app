import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/network/network_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../auth/presentation/states/auth_state.dart';
import '../../data/datasources/local/orders_local_datasource.dart';
import '../../data/datasources/orders_datasource.dart';
import '../../data/datasources/remote/orders_remote_datasource.dart';
import '../../data/repositories/orders_repository_impl.dart';
import '../../domain/repositories/orders_repository.dart';
import '../../domain/services/order_id_transition_registry.dart';
import '../../domain/usecases/orders_usecase.dart';
import '../../data/sync/orders_sync_coordinator.dart';
import '../controllers/orders_controller.dart';

final orderIdTransitionRegistryProvider =
    Provider<OrderIdTransitionRegistry>((ref) {
  final registry = OrderIdTransitionRegistry();

  ref.listen<AuthState>(
    authProvider.select((controller) => controller.state),
    (previous, current) {
      if ((previous?.isAuthenticated == true && !current.isAuthenticated) ||
          (previous?.user?.id != null &&
              current.user?.id != null &&
              previous!.user!.id != current.user!.id)) {
        registry.clear();
      }
    },
  );

  ref.onDispose(registry.clear);

  return registry;
});

final ordersLocalDataSourceProvider = Provider<OrdersLocalDataSource>((ref) {
  return OrdersLocalDataSource(ref.watch(appDatabaseProvider));
});

/// Local orders remain the source of truth for reads.
final ordersDataSourceProvider = Provider<OrdersDataSource>((ref) {
  return ref.watch(ordersLocalDataSourceProvider);
});

final ordersSyncCoordinatorProvider = Provider<OrdersSyncCoordinator>((ref) {
  return OrdersSyncCoordinator(
    database: ref.watch(appDatabaseProvider),
    localDataSource: ref.watch(ordersLocalDataSourceProvider),
    remoteDataSource: ref.watch(ordersRemoteDataSourceProvider),
    transitionRegistry: ref.watch(orderIdTransitionRegistryProvider),
  );
});

/// The generated remote API is currently used for creating orders.
///
/// GET /orders and remote status updates are not present in the
/// current generated OpenAPI contract.
final ordersRemoteDataSourceProvider = Provider<OrdersDataSource>((ref) {
  return OrdersRemoteDataSource(
    generatedApiClient: ref.watch(generatedApiClientProvider),
  );
});

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepositoryImpl(
    ref.watch(ordersLocalDataSourceProvider),
    remoteDataSource: ref.watch(ordersRemoteDataSourceProvider),
  );
});

final ordersUseCaseProvider = Provider<OrdersUseCase>((ref) {
  return OrdersUseCase(ref.watch(ordersRepositoryProvider));
});

final ordersProvider = ChangeNotifierProvider<OrdersController>((ref) {
  return OrdersController(
    ref.watch(ordersUseCaseProvider),
    transitionRegistry: ref.watch(orderIdTransitionRegistryProvider),
  );
});

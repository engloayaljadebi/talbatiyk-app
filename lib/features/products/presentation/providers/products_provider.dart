import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/core/network/network_providers.dart';

import '../../data/datasources/local/products_discovery_local_datasource.dart';
import '../../data/datasources/local/products_local_datasource.dart';
import '../../data/datasources/products_datasource.dart';
import '../../data/datasources/products_offline_first_datasource.dart';
import '../../data/datasources/remote/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/products_usecase.dart';
import '../controllers/products_controller.dart';

/// Drift source used only for supplier product management.
///
/// Business writes in this flow may create Outbox operations.
final productsLocalDataSourceProvider = Provider<ProductsLocalDataSource>((
  ref,
) {
  return ProductsLocalDataSource(ref.watch(appDatabaseProvider));
});

/// Product source used by the existing supplier-management Repository.
final productsDataSourceProvider = Provider<ProductsDataSource>((ref) {
  return ref.watch(productsLocalDataSourceProvider);
});

/// Drift cache dedicated to customer Product Discovery.
///
/// Keeping it separate prevents server refreshes from mutating supplier
/// ProductRecords or their pending Outbox state.
final productDiscoveryLocalDataSourceProvider =
    Provider<ProductsDiscoveryLocalDataSource>((ref) {
      return ProductsDiscoveryLocalDataSource(ref.watch(appDatabaseProvider));
    });

/// Raw generated-API source for customer Product Discovery.
final productDiscoveryRemoteDataSourceProvider = Provider<ProductsDataSource>((
  ref,
) {
  return ProductsRemoteDataSource(ref.watch(generatedApiClientProvider));
});

/// Offline-capable Product Discovery source.
///
/// Success: Remote -> dedicated Drift snapshot -> local read.
/// Failure: existing dedicated Drift snapshot -> local read.
final productDiscoveryDataSourceProvider = Provider<ProductsDataSource>((ref) {
  return ProductsOfflineFirstDataSource(
    localDataSource: ref.watch(productDiscoveryLocalDataSourceProvider),
    remoteDataSource: ref.watch(productDiscoveryRemoteDataSourceProvider),
  );
});

final productDiscoveryRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productDiscoveryDataSourceProvider));
});

final productDiscoveryUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(ref.watch(productDiscoveryRepositoryProvider));
});

/// Shared by ProductsPage and LatestProductsSection.
///
/// Presentation remains unaware of network/cache decisions.
final productDiscoveryProvider = ChangeNotifierProvider<ProductsController>((
  ref,
) {
  return ProductsController(ref.watch(productDiscoveryUseCaseProvider));
});

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productsDataSourceProvider));
});

final productsUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(ref.watch(productsRepositoryProvider));
});

/// Controller for local supplier product management.
final productsProvider = ChangeNotifierProvider<ProductsController>((ref) {
  return ProductsController(ref.watch(productsUseCaseProvider));
});

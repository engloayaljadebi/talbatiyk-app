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
/// Concrete Laravel product source.
///
/// Publishing يحتاج الإمكانات الإضافية الخاصة بالإنشاء، بينما Discovery
/// يعتمد فقط على ProductsDataSource حتى يبقى قابلاً للاستبدال في الاختبارات.
final productsRemoteDataSourceProvider = Provider<ProductsRemoteDataSource>((
  ref,
) {
  return ProductsRemoteDataSource(ref.watch(generatedApiClientProvider));
});

final productDiscoveryRemoteDataSourceProvider = Provider<ProductsDataSource>((
  ref,
) {
  return ref.watch(productsRemoteDataSourceProvider);
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

/// Online-only repository used when a supplier publishes a NEW product.
///
/// It deliberately does not use ProductsLocalDataSource for create, therefore
/// a successful create means Laravel persisted the product.
final productPublishingRepositoryProvider = Provider<ProductsRepository>((ref) {
  final local = ref.watch(productsLocalDataSourceProvider);
  final remote = ref.watch(productsRemoteDataSourceProvider);

  /*
   * القراءة المحلية تحفظ تجربة إدارة المورد Local-First.
   * الإنشاء الجديد يذهب إلى Laravel أولًا.
   * ProductsRepositoryImpl يحفظ النسخة الرسمية الراجعة من الخادم محليًا
   * بحالة synced وبدون Outbox إضافي.
   */
  return ProductsRepositoryImpl(local, createDataSource: remote);
});

final productPublishingUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(ref.watch(productPublishingRepositoryProvider));
});

/// Dedicated controller for NEW online product publishing.
///
/// autoLoad is disabled because the publishing screen only needs create.
final productPublishingProvider = Provider<ProductsController>((ref) {
  final controller = ProductsController(
    ref.watch(productPublishingUseCaseProvider),
    autoLoad: false,
  );

  ref.onDispose(controller.dispose);

  return controller;
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

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/core/network/network_providers.dart';

import '../../data/datasources/local/products_local_datasource.dart';
import '../../data/datasources/products_datasource.dart';
import '../../data/datasources/remote/products_remote_datasource.dart';
import '../../data/repositories/products_repository_impl.dart';
import '../../domain/repositories/products_repository.dart';
import '../../domain/usecases/products_usecase.dart';
import '../controllers/products_controller.dart';

/// يوفر مصدر المنتجات المستخدم حاليًا.
///
/// نستخدم قاعدة البيانات المحلية الآن، ويمكن لاحقًا إضافة المصدر البعيد
/// دون تغيير صفحات المنتجات أو الـController.
final productsDataSourceProvider = Provider<ProductsDataSource>((ref) {
  final database = ref.watch(appDatabaseProvider);

  return ProductsLocalDataSource(database);
});

/// Remote read-only source for customer Product Discovery.
final productDiscoveryDataSourceProvider = Provider<ProductsDataSource>((ref) {
  final apiClient = ref.watch(generatedApiClientProvider);

  return ProductsRemoteDataSource(apiClient);
});

/// Repository used only by the Product Discovery read flow.
final productDiscoveryRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productDiscoveryDataSourceProvider));
});

/// Use case used only by the Product Discovery read flow.
final productDiscoveryUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(ref.watch(productDiscoveryRepositoryProvider));
});

/// Controller for remote customer Product Discovery.
final productDiscoveryProvider = ChangeNotifierProvider<ProductsController>((
  ref,
) {
  return ProductsController(ref.watch(productDiscoveryUseCaseProvider));
});

/// يربط مصدر البيانات بطبقة Repository.
final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(ref.watch(productsDataSourceProvider));
});

/// يوفر العمليات التي تستطيع الواجهة تنفيذها على المنتجات.
final productsUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(ref.watch(productsRepositoryProvider));
});

/// يدير حالة المنتجات والبحث والفلترة داخل الواجهة.
final productsProvider = ChangeNotifierProvider<ProductsController>((ref) {
  return ProductsController(ref.watch(productsUseCaseProvider));
});

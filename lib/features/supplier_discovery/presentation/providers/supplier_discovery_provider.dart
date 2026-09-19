import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/remote/supplier_discovery_remote_datasource.dart';
import '../../data/repositories/supplier_discovery_repository_impl.dart';
import '../../domain/repositories/supplier_discovery_repository.dart';
import '../../domain/usecases/supplier_discovery_usecase.dart';
import '../controllers/supplier_discovery_controller.dart';

final supplierDiscoveryRemoteDataSourceProvider =
    Provider<SupplierDiscoveryRemoteDataSource>((ref) {
      return SupplierDiscoveryRemoteDataSourceImpl(
        ref.watch(generatedApiClientProvider),
      );
    });

final supplierDiscoveryRepositoryProvider =
    Provider<SupplierDiscoveryRepository>((ref) {
      return SupplierDiscoveryRepositoryImpl(
        ref.watch(supplierDiscoveryRemoteDataSourceProvider),
      );
    });

final supplierDiscoveryUseCaseProvider = Provider<SupplierDiscoveryUseCase>((
  ref,
) {
  return SupplierDiscoveryUseCase(
    ref.watch(supplierDiscoveryRepositoryProvider),
  );
});

final supplierDiscoveryControllerProvider =
    ChangeNotifierProvider<SupplierDiscoveryController>((ref) {
      return SupplierDiscoveryController(
        ref.watch(supplierDiscoveryUseCaseProvider),
      );
    });

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/core/network/network_providers.dart';

import '../../data/datasources/supplier_follow_remote_datasource.dart';
import '../../data/repositories/supplier_follow_repository_impl.dart';
import '../../domain/repositories/supplier_follow_repository.dart';
import '../../domain/usecases/supplier_follow_usecase.dart';
import '../controllers/supplier_follow_controller.dart';

final supplierFollowRemoteDataSourceProvider =
    Provider<SupplierFollowRemoteDataSource>((ref) {
      return SupplierFollowRemoteDataSourceImpl(
        ref.watch(generatedApiClientProvider),
      );
    });

final supplierFollowRepositoryProvider = Provider<SupplierFollowRepository>((
  ref,
) {
  return SupplierFollowRepositoryImpl(
    ref.watch(supplierFollowRemoteDataSourceProvider),
  );
});

final supplierFollowUseCaseProvider = Provider<SupplierFollowUseCase>((ref) {
  return SupplierFollowUseCase(ref.watch(supplierFollowRepositoryProvider));
});

final supplierFollowProvider =
    ChangeNotifierProvider.family<SupplierFollowController, String>((
      ref,
      businessId,
    ) {
      return SupplierFollowController(
        ref.watch(supplierFollowUseCaseProvider),
        businessId,
      );
    });

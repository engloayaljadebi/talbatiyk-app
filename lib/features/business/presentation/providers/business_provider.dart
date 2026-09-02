import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/remote/business_remote_datasource.dart';
import '../../data/repositories/business_repository_impl.dart';
import '../../domain/repositories/business_repository.dart';
import '../../domain/usecases/business_usecase.dart';
import '../controllers/business_controller.dart';

final businessRemoteDataSourceProvider = Provider<BusinessRemoteDataSource>((
  ref,
) {
  return BusinessRemoteDataSourceImpl(ref.watch(generatedApiClientProvider));
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(ref.watch(businessRemoteDataSourceProvider));
});

final businessUseCaseProvider = Provider<BusinessUseCase>((ref) {
  return BusinessUseCase(ref.watch(businessRepositoryProvider));
});

final businessControllerProvider =
    ChangeNotifierProvider.autoDispose<BusinessController>((ref) {
      final controller = BusinessController(ref.watch(businessUseCaseProvider));

      unawaited(controller.loadBusinesses());

      return controller;
    });

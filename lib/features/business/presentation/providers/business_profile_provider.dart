import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_providers.dart';
import '../../data/datasources/remote/business_profile_remote_datasource.dart';
import '../../data/repositories/business_profile_repository_impl.dart';
import '../../domain/entities/business_entity.dart';
import '../../domain/repositories/business_profile_repository.dart';
import '../../domain/usecases/update_business_profile_usecase.dart';
import '../controllers/business_profile_controller.dart';

final businessProfileRemoteDataSourceProvider =
    Provider<BusinessProfileRemoteDataSource>((ref) {
      return BusinessProfileRemoteDataSourceImpl(
        ref.watch(generatedApiClientProvider),
      );
    });

final businessProfileRepositoryProvider = Provider<BusinessProfileRepository>((
  ref,
) {
  return BusinessProfileRepositoryImpl(
    ref.watch(businessProfileRemoteDataSourceProvider),
  );
});

final updateBusinessProfileUseCaseProvider =
    Provider<UpdateBusinessProfileUseCase>((ref) {
      return UpdateBusinessProfileUseCase(
        ref.watch(businessProfileRepositoryProvider),
      );
    });

final businessProfileControllerProvider = ChangeNotifierProvider.autoDispose
    .family<BusinessProfileController, BusinessEntity>((ref, business) {
      return BusinessProfileController(
        ref.watch(updateBusinessProfileUseCaseProvider),
        business,
      );
    });

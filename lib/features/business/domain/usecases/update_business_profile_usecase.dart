import '../entities/business_entity.dart';
import '../entities/business_profile_update.dart';
import '../repositories/business_profile_repository.dart';

final class UpdateBusinessProfileUseCase {
  const UpdateBusinessProfileUseCase(this._repository);

  final BusinessProfileRepository _repository;

  Future<BusinessEntity> call({
    required String businessId,
    required BusinessProfileUpdate update,
  }) {
    return _repository.updateProfile(businessId: businessId, update: update);
  }
}

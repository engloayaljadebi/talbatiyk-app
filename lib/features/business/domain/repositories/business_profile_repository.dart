import '../entities/business_entity.dart';
import '../entities/business_profile_update.dart';

abstract interface class BusinessProfileRepository {
  Future<BusinessEntity> updateProfile({
    required String businessId,
    required BusinessProfileUpdate update,
  });
}

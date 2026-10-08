import '../../domain/entities/business_entity.dart';
import '../../domain/entities/business_profile_update.dart';
import '../../domain/repositories/business_profile_repository.dart';
import '../datasources/remote/business_profile_remote_datasource.dart';
import '../mappers/business_mapper.dart';

final class BusinessProfileRepositoryImpl implements BusinessProfileRepository {
  const BusinessProfileRepositoryImpl(this._remoteDataSource);

  final BusinessProfileRemoteDataSource _remoteDataSource;

  @override
  Future<BusinessEntity> updateProfile({
    required String businessId,
    required BusinessProfileUpdate update,
  }) async {
    final resource = await _remoteDataSource.updateProfile(
      businessId: businessId,
      update: update,
    );

    return BusinessMapper.toEntity(resource);
  }
}

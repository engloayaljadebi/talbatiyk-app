import '../../domain/entities/business_entity.dart';
import '../../domain/repositories/business_repository.dart';
import '../datasources/remote/business_remote_datasource.dart';
import '../mappers/business_mapper.dart';

final class BusinessRepositoryImpl implements BusinessRepository {
  const BusinessRepositoryImpl(this._remoteDataSource);

  final BusinessRemoteDataSource _remoteDataSource;

  @override
  Future<List<BusinessEntity>> getAccessibleBusinesses() async {
    final resources = await _remoteDataSource.index();

    return List<BusinessEntity>.unmodifiable(
      resources.map(BusinessMapper.toEntity),
    );
  }
}

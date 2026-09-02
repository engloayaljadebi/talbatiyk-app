import '../../domain/entities/supplier_candidate_entity.dart';
import '../../domain/repositories/supplier_discovery_repository.dart';
import '../datasources/remote/supplier_discovery_remote_datasource.dart';
import '../mappers/supplier_discovery_mapper.dart';

final class SupplierDiscoveryRepositoryImpl
    implements SupplierDiscoveryRepository {
  const SupplierDiscoveryRepositoryImpl(this._remoteDataSource);

  final SupplierDiscoveryRemoteDataSource _remoteDataSource;

  @override
  Future<List<SupplierCandidateEntity>> getSuppliers() async {
    final resources = await _remoteDataSource.index();

    return List<SupplierCandidateEntity>.unmodifiable(
      resources.map(SupplierDiscoveryMapper.fromResource),
    );
  }
}

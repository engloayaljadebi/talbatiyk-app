import '../../../auth/domain/services/account_session_fence.dart';
import '../../domain/entities/supplier_candidate_entity.dart';
import '../../domain/repositories/supplier_discovery_repository.dart';
import '../datasources/remote/supplier_discovery_remote_datasource.dart';
import '../mappers/supplier_discovery_mapper.dart';

final class SupplierDiscoveryRepositoryImpl
    implements SupplierDiscoveryRepository {
  const SupplierDiscoveryRepositoryImpl(
    this._remoteDataSource,
    this._sessionFence,
  );

  final SupplierDiscoveryRemoteDataSource _remoteDataSource;
  final AccountSessionFence _sessionFence;

  @override
  Future<List<SupplierCandidateEntity>> getSuppliers() async {
    final lease = _sessionFence.capture();
    final resources = await _remoteDataSource.index();
    lease.ensureCurrent();

    return List<SupplierCandidateEntity>.unmodifiable(
      resources.map(SupplierDiscoveryMapper.fromResource),
    );
  }
}

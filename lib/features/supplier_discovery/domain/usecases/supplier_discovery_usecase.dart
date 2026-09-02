import '../entities/supplier_candidate_entity.dart';
import '../repositories/supplier_discovery_repository.dart';

final class SupplierDiscoveryUseCase {
  const SupplierDiscoveryUseCase(this._repository);

  final SupplierDiscoveryRepository _repository;

  Future<List<SupplierCandidateEntity>> getSuppliers() {
    return _repository.getSuppliers();
  }
}

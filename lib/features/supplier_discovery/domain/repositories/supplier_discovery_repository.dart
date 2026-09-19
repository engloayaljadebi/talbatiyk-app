import '../entities/supplier_candidate_entity.dart';

abstract interface class SupplierDiscoveryRepository {
  Future<List<SupplierCandidateEntity>> getSuppliers();
}

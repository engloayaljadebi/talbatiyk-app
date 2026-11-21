import 'package:talbytk_api/talbytk_api.dart';

import '../../domain/entities/supplier_candidate_entity.dart';

final class SupplierDiscoveryMapper {
  const SupplierDiscoveryMapper._();

  static SupplierCandidateEntity fromResource(
    SupplierSummaryResource resource,
  ) {
    return SupplierCandidateEntity(id: resource.id, name: resource.name);
  }
}

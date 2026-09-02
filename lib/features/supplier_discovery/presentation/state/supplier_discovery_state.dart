import '../../domain/entities/supplier_candidate_entity.dart';

final class SupplierDiscoveryState {
  const SupplierDiscoveryState({
    this.suppliers = const <SupplierCandidateEntity>[],
    this.isLoading = false,
    this.errorMessage,
  });

  final List<SupplierCandidateEntity> suppliers;
  final bool isLoading;
  final String? errorMessage;
}

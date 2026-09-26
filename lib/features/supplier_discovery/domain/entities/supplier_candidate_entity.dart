final class SupplierCandidateEntity {
  const SupplierCandidateEntity({
    required this.id,
    required this.name,
    this.isFromCache = false,
  });

  final String id;
  final String name;
  final bool isFromCache;
}

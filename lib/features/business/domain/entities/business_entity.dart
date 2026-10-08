final class BusinessEntity {
  const BusinessEntity({
    required this.id,
    required this.name,
    this.legalName,
    this.description,
    this.location,
  });

  final String id;
  final String name;
  final String? legalName;
  final String? description;
  final String? location;
}

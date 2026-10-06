final class BusinessEntity {
  const BusinessEntity({
    required this.id,
    required this.name,
    this.description,
    this.location,
  });

  final String id;
  final String name;
  final String? description;
  final String? location;
}

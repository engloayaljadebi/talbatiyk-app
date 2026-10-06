import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../domain/entities/business_entity.dart';

abstract final class BusinessMapper {
  static BusinessEntity toEntity(BusinessResource resource) {
    final resolvedDescription = resource.description?.trim();
    final resolvedLocation = _resolveLocation(resource.primaryLocation);

    return BusinessEntity(
      id: resource.id,
      name: resource.name,
      description: resolvedDescription == null || resolvedDescription.isEmpty
          ? null
          : resolvedDescription,
      location: resolvedLocation,
    );
  }

  static String? _resolveLocation(BusinessLocationResource? primaryLocation) {
    final address = primaryLocation?.address;
    if (address == null) {
      return null;
    }

    final parts = <String>[
      address.streetAddress?.trim() ?? '',
      address.district?.trim() ?? '',
      address.locality?.trim() ?? '',
      address.administrativeArea?.trim() ?? '',
      address.countryCode.trim(),
    ].where((part) => part.trim().isNotEmpty).toList();

    if (parts.isEmpty) {
      return null;
    }

    return parts.join(', ');
  }
}

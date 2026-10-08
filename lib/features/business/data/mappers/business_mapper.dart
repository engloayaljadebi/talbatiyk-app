import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../domain/entities/business_entity.dart';

abstract final class BusinessMapper {
  static BusinessEntity toEntity(BusinessResource resource) {
    final resolvedLegalName = _clean(resource.legalName);
    final resolvedDescription = _clean(resource.description);
    final resolvedLocation = _resolveLocation(resource.primaryLocation);

    return BusinessEntity(
      id: resource.id,
      name: resource.name,
      legalName: resolvedLegalName,
      description: resolvedDescription,
      location: resolvedLocation,
    );
  }

  static String? _clean(String? value) {
    final normalized = value?.trim();

    return normalized == null || normalized.isEmpty ? null : normalized;
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
    ].where((part) => part.isNotEmpty).toList();

    return parts.isEmpty ? null : parts.join(', ');
  }
}

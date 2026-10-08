import '../../domain/entities/business_profile_update.dart';

abstract final class BusinessProfilePatchMapper {
  static Map<String, Object?> toJson(BusinessProfileUpdate update) {
    final payload = <String, Object?>{};

    final name = update.name;

    if (name != null) {
      payload['name'] = name;
    }

    if (update.legalName.isPresent) {
      payload['legal_name'] = update.legalName.value;
    }

    if (update.description.isPresent) {
      payload['description'] = update.description.value;
    }

    return Map<String, Object?>.unmodifiable(payload);
  }
}

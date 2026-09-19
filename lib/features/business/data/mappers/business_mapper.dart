import 'package:talbatiyk_api/talbatiyk_api.dart';

import '../../domain/entities/business_entity.dart';

abstract final class BusinessMapper {
  static BusinessEntity toEntity(BusinessResource resource) {
    return BusinessEntity(id: resource.id, name: resource.name);
  }
}

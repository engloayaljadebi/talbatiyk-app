import '../entities/business_entity.dart';

abstract interface class BusinessRepository {
  Future<List<BusinessEntity>> getAccessibleBusinesses();
}

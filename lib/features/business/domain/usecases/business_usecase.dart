import '../entities/business_entity.dart';
import '../repositories/business_repository.dart';

final class BusinessUseCase {
  const BusinessUseCase(this._repository);

  final BusinessRepository _repository;

  Future<List<BusinessEntity>> getAccessibleBusinesses() {
    return _repository.getAccessibleBusinesses();
  }
}

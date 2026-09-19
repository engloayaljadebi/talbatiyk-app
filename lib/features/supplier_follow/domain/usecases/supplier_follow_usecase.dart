import '../repositories/supplier_follow_repository.dart';

final class SupplierFollowUseCase {
  SupplierFollowUseCase(this._repository);

  final SupplierFollowRepository _repository;

  Future<bool> isFollowing(String businessId) {
    return _repository.isFollowing(_normalizeBusinessId(businessId));
  }

  Future<bool> follow(String businessId) {
    return _repository.follow(_normalizeBusinessId(businessId));
  }

  Future<bool> unfollow(String businessId) {
    return _repository.unfollow(_normalizeBusinessId(businessId));
  }

  String _normalizeBusinessId(String businessId) {
    final normalizedId = businessId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError.value(
        businessId,
        'businessId',
        'Supplier business ID cannot be empty.',
      );
    }

    return normalizedId;
  }
}

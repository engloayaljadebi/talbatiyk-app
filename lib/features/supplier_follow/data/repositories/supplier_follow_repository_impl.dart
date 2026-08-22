import '../../domain/repositories/supplier_follow_repository.dart';
import '../datasources/supplier_follow_remote_datasource.dart';

final class SupplierFollowRepositoryImpl implements SupplierFollowRepository {
  SupplierFollowRepositoryImpl(this._remoteDataSource);

  final SupplierFollowRemoteDataSource _remoteDataSource;

  @override
  Future<bool> isFollowing(String businessId) {
    return _remoteDataSource.isFollowing(businessId);
  }

  @override
  Future<bool> follow(String businessId) {
    return _remoteDataSource.follow(businessId);
  }

  @override
  Future<bool> unfollow(String businessId) {
    return _remoteDataSource.unfollow(businessId);
  }
}

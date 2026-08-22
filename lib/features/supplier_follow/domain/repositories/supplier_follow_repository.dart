abstract interface class SupplierFollowRepository {
  Future<bool> isFollowing(String businessId);

  Future<bool> follow(String businessId);

  Future<bool> unfollow(String businessId);
}

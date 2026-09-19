import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/supplier_follow/domain/repositories/supplier_follow_repository.dart';
import 'package:talbatiyk/features/supplier_follow/domain/usecases/supplier_follow_usecase.dart';

void main() {
  group('SupplierFollowUseCase', () {
    late _FakeSupplierFollowRepository repository;
    late SupplierFollowUseCase useCase;

    setUp(() {
      repository = _FakeSupplierFollowRepository();
      useCase = SupplierFollowUseCase(repository);
    });

    test('isFollowing trims business id and delegates to repository', () async {
      repository.isFollowingResult = true;

      final result = await useCase.isFollowing('  supplier-1  ');

      expect(result, isTrue);
      expect(repository.isFollowingCalls, 1);
      expect(repository.receivedBusinessId, 'supplier-1');
    });

    test('follow delegates to repository', () async {
      repository.followResult = true;

      final result = await useCase.follow('supplier-2');

      expect(result, isTrue);
      expect(repository.followCalls, 1);
      expect(repository.receivedBusinessId, 'supplier-2');
    });

    test('unfollow delegates to repository', () async {
      repository.unfollowResult = false;

      final result = await useCase.unfollow('supplier-3');

      expect(result, isFalse);
      expect(repository.unfollowCalls, 1);
      expect(repository.receivedBusinessId, 'supplier-3');
    });

    test('rejects empty business id before repository call', () {
      expect(() => useCase.isFollowing('   '), throwsArgumentError);
      expect(() => useCase.follow('   '), throwsArgumentError);
      expect(() => useCase.unfollow('   '), throwsArgumentError);

      expect(repository.totalCalls, 0);
    });
  });
}

final class _FakeSupplierFollowRepository implements SupplierFollowRepository {
  bool isFollowingResult = false;
  bool followResult = true;
  bool unfollowResult = false;

  int isFollowingCalls = 0;
  int followCalls = 0;
  int unfollowCalls = 0;

  String? receivedBusinessId;

  int get totalCalls => isFollowingCalls + followCalls + unfollowCalls;

  @override
  Future<bool> isFollowing(String businessId) async {
    isFollowingCalls += 1;
    receivedBusinessId = businessId;
    return isFollowingResult;
  }

  @override
  Future<bool> follow(String businessId) async {
    followCalls += 1;
    receivedBusinessId = businessId;
    return followResult;
  }

  @override
  Future<bool> unfollow(String businessId) async {
    unfollowCalls += 1;
    receivedBusinessId = businessId;
    return unfollowResult;
  }
}

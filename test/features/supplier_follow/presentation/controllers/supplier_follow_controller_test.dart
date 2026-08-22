import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/supplier_follow/domain/repositories/supplier_follow_repository.dart';
import 'package:talbatiyk/features/supplier_follow/domain/usecases/supplier_follow_usecase.dart';
import 'package:talbatiyk/features/supplier_follow/presentation/controllers/supplier_follow_controller.dart';

void main() {
  group('SupplierFollowController', () {
    late _FakeSupplierFollowRepository repository;
    late SupplierFollowController controller;

    setUp(() {
      repository = _FakeSupplierFollowRepository();

      controller = SupplierFollowController(
        SupplierFollowUseCase(repository),
        'supplier-1',
        autoLoad: false,
      );
    });

    tearDown(() => controller.dispose());

    test('loads current follow status', () async {
      repository.isFollowingResult = true;

      await controller.loadStatus();

      expect(controller.isLoading, isFalse);
      expect(controller.isFollowing, isTrue);
      expect(controller.errorMessage, isNull);
      expect(controller.canToggle, isTrue);
    });

    test('sets error when loading status fails', () async {
      repository.isFollowingError = StateError('network failed');

      await controller.loadStatus();

      expect(controller.isLoading, isFalse);
      expect(controller.isFollowing, isNull);
      expect(controller.errorMessage, 'تعذر تحميل حالة متابعة المورد.');
      expect(controller.canToggle, isFalse);
    });

    test('follows supplier when current status is false', () async {
      repository.isFollowingResult = false;
      repository.followResult = true;

      await controller.loadStatus();
      final result = await controller.toggle();

      expect(result, isTrue);
      expect(controller.isFollowing, isTrue);
      expect(repository.followCalls, 1);
      expect(repository.unfollowCalls, 0);
    });

    test('unfollows supplier when current status is true', () async {
      repository.isFollowingResult = true;
      repository.unfollowResult = false;

      await controller.loadStatus();
      final result = await controller.toggle();

      expect(result, isFalse);
      expect(controller.isFollowing, isFalse);
      expect(repository.unfollowCalls, 1);
      expect(repository.followCalls, 0);
    });

    test('keeps previous status when mutation fails', () async {
      repository.isFollowingResult = false;
      repository.followError = StateError('request failed');

      await controller.loadStatus();
      final result = await controller.toggle();

      expect(result, isFalse);
      expect(controller.isFollowing, isFalse);
      expect(controller.errorMessage, 'تعذر متابعة المورد.');
      expect(controller.isUpdating, isFalse);
    });

    test(
      'prevents duplicate follow mutation while request is running',
      () async {
        repository.isFollowingResult = false;
        repository.followCompleter = Completer<bool>();

        await controller.loadStatus();

        final firstRequest = controller.toggle();

        expect(controller.isUpdating, isTrue);
        expect(repository.followCalls, 1);

        final secondResult = await controller.toggle();

        expect(secondResult, isFalse);
        expect(repository.followCalls, 1);

        repository.followCompleter!.complete(true);

        expect(await firstRequest, isTrue);
        expect(controller.isFollowing, isTrue);
        expect(controller.isUpdating, isFalse);
      },
    );
  });
}

final class _FakeSupplierFollowRepository implements SupplierFollowRepository {
  bool isFollowingResult = false;
  bool followResult = true;
  bool unfollowResult = false;

  Object? isFollowingError;
  Object? followError;
  Object? unfollowError;

  Completer<bool>? followCompleter;

  int followCalls = 0;
  int unfollowCalls = 0;

  @override
  Future<bool> isFollowing(String businessId) async {
    if (isFollowingError case final error?) {
      throw error;
    }

    return isFollowingResult;
  }

  @override
  Future<bool> follow(String businessId) async {
    followCalls += 1;

    if (followError case final error?) {
      throw error;
    }

    final completer = followCompleter;

    if (completer != null) {
      return completer.future;
    }

    return followResult;
  }

  @override
  Future<bool> unfollow(String businessId) async {
    unfollowCalls += 1;

    if (unfollowError case final error?) {
      throw error;
    }

    return unfollowResult;
  }
}

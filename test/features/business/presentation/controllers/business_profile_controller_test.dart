import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/domain/entities/business_profile_update.dart';
import 'package:talbatiyk/features/business/domain/repositories/business_profile_repository.dart';
import 'package:talbatiyk/features/business/domain/usecases/update_business_profile_usecase.dart';
import 'package:talbatiyk/features/business/presentation/controllers/business_profile_controller.dart';

void main() {
  test('save replaces profile with canonical repository result', () async {
    const initial = BusinessEntity(
      id: 'business-1',
      name: 'الاسم القديم',
      legalName: 'الاسم القانوني القديم',
      description: 'الوصف القديم',
      location: 'صنعاء',
    );

    const canonical = BusinessEntity(
      id: 'business-1',
      name: 'الاسم الجديد',
      legalName: null,
      description: 'الوصف الجديد',
      location: 'صنعاء',
    );

    final repository = _FakeBusinessProfileRepository(
      canonicalResult: canonical,
    );

    final controller = BusinessProfileController(
      UpdateBusinessProfileUseCase(repository),
      initial,
    );

    const update = BusinessProfileUpdate(
      name: 'الاسم الجديد',
      legalName: PatchField<String>.present(null),
      description: PatchField<String>.present('الوصف الجديد'),
    );

    final result = await controller.save(update);

    expect(result, same(canonical));
    expect(controller.state.business, same(canonical));
    expect(controller.state.isSaving, isFalse);
    expect(controller.state.errorMessage, isNull);

    expect(repository.lastBusinessId, 'business-1');
    expect(repository.lastUpdate, same(update));
  });

  test('save failure preserves previous profile', () async {
    const initial = BusinessEntity(id: 'business-1', name: 'الاسم الحالي');

    final repository = _FakeBusinessProfileRepository(
      error: StateError('network failed'),
    );

    final controller = BusinessProfileController(
      UpdateBusinessProfileUseCase(repository),
      initial,
    );

    final result = await controller.save(
      const BusinessProfileUpdate(name: 'اسم آخر'),
    );

    expect(result, isNull);
    expect(controller.state.business, same(initial));
    expect(controller.state.isSaving, isFalse);
    expect(controller.state.errorMessage, isNotNull);
  });
}

final class _FakeBusinessProfileRepository
    implements BusinessProfileRepository {
  _FakeBusinessProfileRepository({this.canonicalResult, this.error});

  final BusinessEntity? canonicalResult;
  final Object? error;

  String? lastBusinessId;
  BusinessProfileUpdate? lastUpdate;

  @override
  Future<BusinessEntity> updateProfile({
    required String businessId,
    required BusinessProfileUpdate update,
  }) async {
    lastBusinessId = businessId;
    lastUpdate = update;

    final failure = error;

    if (failure != null) {
      throw failure;
    }

    return canonicalResult!;
  }
}

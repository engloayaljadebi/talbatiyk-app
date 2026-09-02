import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/domain/repositories/business_repository.dart';
import 'package:talbatiyk/features/business/domain/usecases/business_usecase.dart';
import 'package:talbatiyk/features/business/presentation/controllers/business_controller.dart';
import 'package:talbatiyk/features/business/presentation/state/business_state.dart';

void main() {
  test('loadBusinesses exposes accessible businesses', () async {
    final repository = _FakeBusinessRepository(
      businesses: const [BusinessEntity(id: 'business-1', name: 'بيت الجوال')],
    );

    final controller = BusinessController(BusinessUseCase(repository));

    addTearDown(controller.dispose);

    await controller.loadBusinesses();

    expect(controller.state.status, BusinessLoadStatus.loaded);
    expect(controller.state.businesses, hasLength(1));
    expect(controller.state.businesses.single.id, 'business-1');
    expect(controller.state.businesses.single.name, 'بيت الجوال');
  });

  test('loadBusinesses exposes failure without stale businesses', () async {
    final repository = _FakeBusinessRepository(
      error: StateError('network failed'),
    );

    final controller = BusinessController(BusinessUseCase(repository));

    addTearDown(controller.dispose);

    await controller.loadBusinesses();

    expect(controller.state.status, BusinessLoadStatus.failure);
    expect(controller.state.businesses, isEmpty);
    expect(controller.state.errorMessage, isNotEmpty);
  });
}

final class _FakeBusinessRepository implements BusinessRepository {
  const _FakeBusinessRepository({this.businesses = const [], this.error});

  final List<BusinessEntity> businesses;
  final Object? error;

  @override
  Future<List<BusinessEntity>> getAccessibleBusinesses() async {
    final failure = error;

    if (failure != null) {
      throw failure;
    }

    return businesses;
  }
}

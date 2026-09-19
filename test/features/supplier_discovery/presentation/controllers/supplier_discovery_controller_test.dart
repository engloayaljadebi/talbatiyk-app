import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/repositories/supplier_discovery_repository.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/usecases/supplier_discovery_usecase.dart';
import 'package:talbatiyk/features/supplier_discovery/presentation/controllers/supplier_discovery_controller.dart';

void main() {
  test('loadSuppliers exposes server candidates', () async {
    final repository = _FakeSupplierDiscoveryRepository(
      suppliers: const [
        SupplierCandidateEntity(id: 'supplier-a', name: 'Supplier A'),
        SupplierCandidateEntity(id: 'supplier-b', name: 'Supplier B'),
      ],
    );

    final controller = SupplierDiscoveryController(
      SupplierDiscoveryUseCase(repository),
    );

    final loaded = await controller.loadSuppliers();

    expect(loaded, isTrue);
    expect(controller.state.isLoading, isFalse);
    expect(controller.state.errorMessage, isNull);
    expect(controller.state.suppliers.map((supplier) => supplier.id), [
      'supplier-a',
      'supplier-b',
    ]);
  });

  test('loadSuppliers clears stale candidates on failure', () async {
    final repository = _FakeSupplierDiscoveryRepository(
      suppliers: const [
        SupplierCandidateEntity(id: 'supplier-a', name: 'Supplier A'),
      ],
    );

    final controller = SupplierDiscoveryController(
      SupplierDiscoveryUseCase(repository),
    );

    expect(await controller.loadSuppliers(), isTrue);

    repository.error = StateError('network failed');

    expect(await controller.loadSuppliers(), isFalse);
    expect(controller.state.suppliers, isEmpty);
    expect(controller.state.errorMessage, isNotNull);
    expect(controller.state.isLoading, isFalse);
  });
}

final class _FakeSupplierDiscoveryRepository
    implements SupplierDiscoveryRepository {
  _FakeSupplierDiscoveryRepository({required this.suppliers});

  final List<SupplierCandidateEntity> suppliers;
  Object? error;

  @override
  Future<List<SupplierCandidateEntity>> getSuppliers() async {
    final currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    return suppliers;
  }
}

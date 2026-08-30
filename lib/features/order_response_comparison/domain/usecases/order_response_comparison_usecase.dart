import '../entities/order_response_comparison_entity.dart';
import '../repositories/order_response_comparison_repository.dart';

final class OrderResponseComparisonUseCase {
  OrderResponseComparisonUseCase(this._repository);

  final OrderResponseComparisonRepository _repository;

  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  }) {
    return _repository.getComparison(orderId: orderId);
  }

  Future<OrderResponseComparisonEntity> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  }) {
    return _repository.replaceSelections(
      orderId: orderId,
      expectedVersion: expectedVersion,
      selections: selections,
    );
  }
}

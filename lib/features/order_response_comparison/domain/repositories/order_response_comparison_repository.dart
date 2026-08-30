import '../entities/order_response_comparison_entity.dart';

abstract interface class OrderResponseComparisonRepository {
  Future<OrderResponseComparisonEntity> getComparison({
    required String orderId,
  });

  Future<OrderResponseComparisonEntity> replaceSelections({
    required String orderId,
    required int expectedVersion,
    required List<OrderResponseSelectionInput> selections,
  });
}

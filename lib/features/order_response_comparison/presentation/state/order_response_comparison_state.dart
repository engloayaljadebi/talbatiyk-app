import '../../domain/entities/order_response_comparison_entity.dart';

final class OrderResponseComparisonState {
  const OrderResponseComparisonState({
    this.comparison,
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final OrderResponseComparisonEntity? comparison;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;

  OrderResponseComparisonState copyWith({
    OrderResponseComparisonEntity? comparison,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return OrderResponseComparisonState(
      comparison: comparison ?? this.comparison,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

import '../../domain/entities/orders_entity.dart';

class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.lastCreatedOrder,
  });

  final List<OrderEntity> orders;
  final bool isLoading;
  final bool isSubmitting;
  final String? errorMessage;
  final OrderEntity? lastCreatedOrder;

  OrdersState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    bool? isSubmitting,
    String? errorMessage,
    bool clearErrorMessage = false,
    OrderEntity? lastCreatedOrder,
    bool clearLastCreatedOrder = false,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
      lastCreatedOrder: clearLastCreatedOrder
          ? null
          : lastCreatedOrder ?? this.lastCreatedOrder,
    );
  }
}

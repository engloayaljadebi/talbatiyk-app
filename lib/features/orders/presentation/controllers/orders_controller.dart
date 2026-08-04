import 'package:flutter/foundation.dart';

import '../../domain/entities/orders_entity.dart';
import '../../domain/usecases/orders_usecase.dart';
import '../state/orders_state.dart';

class OrdersController extends ChangeNotifier {
  OrdersController(this._useCase, {bool autoLoad = true}) {
    if (autoLoad) loadOrders();
  }

  final OrdersUseCase _useCase;

  OrdersState state = const OrdersState();

  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    notifyListeners();

    try {
      final orders = await _useCase.getOrders();

      state = state.copyWith(
        orders: orders,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل الطلبيات، حاول مرة أخرى',
      );
    }

    notifyListeners();
  }

  Future<OrderEntity?> createOrder(CreateOrderRequest request) async {
    if (state.isSubmitting) return null;

    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearLastCreatedOrder: true,
    );
    notifyListeners();

    try {
      final order = await _useCase.createOrder(request);
      final orders = [
        order,
        ...state.orders.where((item) => item.id != order.id),
      ];

      state = state.copyWith(
        orders: List<OrderEntity>.unmodifiable(orders),
        isSubmitting: false,
        lastCreatedOrder: order,
        clearErrorMessage: true,
      );
      notifyListeners();
      return order;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'تعذر إرسال الطلبية، حاول مرة أخرى',
      );
      notifyListeners();
      return null;
    }
  }
}

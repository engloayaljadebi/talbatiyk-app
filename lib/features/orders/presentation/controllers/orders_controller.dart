import 'package:flutter/foundation.dart';

import '../../domain/entities/orders_entity.dart';
import '../../domain/usecases/orders_usecase.dart';
import '../state/orders_state.dart';

/// المتحكم المسؤول عن إدارة الطلبيات وحالات واجهتها.
///
/// المهام:
/// - تحميل الطلبيات.
/// - إنشاء طلبية جديدة.
/// - البحث عن طلبية.
/// - تحديث حالة الطلبية عبر طبقات المشروع.
/// - معالجة حالات التحميل والأخطاء.
class OrdersController extends ChangeNotifier {
  OrdersController(this._useCase, {bool autoLoad = true}) {
    if (autoLoad) {
      loadOrders();
    }
  }

  final OrdersUseCase _useCase;

  OrdersState state = const OrdersState();

  /// البحث عن طلبية بواسطة المعرّف.
  OrderEntity? findOrderById(String orderId) {
    for (final OrderEntity order in state.orders) {
      if (order.id == orderId) {
        return order;
      }
    }

    return null;
  }

  /// تحديث حالة الطلبية من خلال:
  ///
  /// Controller → UseCase → Repository → DataSource
  Future<void> loadOrders() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    notifyListeners();

    try {
      final List<OrderEntity> orders = await _useCase.getOrders();

      state = state.copyWith(
        orders: List<OrderEntity>.unmodifiable(orders),
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

  /// إنشاء طلبية جديدة.
  Future<OrderEntity?> createOrder(CreateOrderRequest request) async {
    if (state.isSubmitting) {
      return null;
    }

    state = state.copyWith(
      isSubmitting: true,
      clearErrorMessage: true,
      clearLastCreatedOrder: true,
    );
    notifyListeners();

    try {
      final OrderEntity order = await _useCase.createOrder(request);

      final List<OrderEntity> orders = [
        order,
        ...state.orders.where((OrderEntity item) => item.id != order.id),
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

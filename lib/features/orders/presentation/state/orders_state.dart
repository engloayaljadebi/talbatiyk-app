import '../../domain/entities/orders_entity.dart';

/// حالة واجهة الطلبات.
///
/// تحتوي على:
/// - قائمة الطلبيات.
/// - حالة التحميل.
/// - حالة إرسال طلبية جديدة.
/// - معرّف الطلبية التي يتم تحديث حالتها.
/// - رسالة الخطأ.
/// - آخر طلبية تم إنشاؤها.
class OrdersState {
  const OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.lastCreatedOrder,
  });

  /// جميع الطلبيات الحالية.
  final List<OrderEntity> orders;

  /// هل يتم تحميل قائمة الطلبيات؟
  final bool isLoading;

  /// هل يتم إرسال طلبية جديدة؟
  final bool isSubmitting;

  /// معرّف الطلبية التي يتم تحديث حالتها حاليًا.
  ///
  /// تكون القيمة null عندما لا توجد عملية تحديث.

  /// رسالة الخطأ الحالية.
  final String? errorMessage;

  /// آخر طلبية تم إنشاؤها.
  final OrderEntity? lastCreatedOrder;

  /// هل توجد عملية تحديث لحالة طلبية؟
  /// إنشاء نسخة جديدة من الحالة مع تعديل القيم المطلوبة فقط.
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

      // حذف معرّف الطلبية بعد انتهاء عملية التحديث.
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,

      // حذف آخر طلبية عند بدء عملية إنشاء جديدة.
      lastCreatedOrder: clearLastCreatedOrder
          ? null
          : lastCreatedOrder ?? this.lastCreatedOrder,
    );
  }
}

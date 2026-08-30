import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/received_order_entity.dart';
import '../../domain/errors/stale_recipient_fulfillment_version_exception.dart';
import '../../domain/usecases/received_orders_usecase.dart';
import '../state/received_orders_state.dart';

final class ReceivedOrdersController extends ChangeNotifier {
  ReceivedOrdersController(
    this._businessId,
    this._useCase, {
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      loadReceivedOrders();
    }
  }

  final String _businessId;
  final ReceivedOrdersUseCase _useCase;

  final Map<String, String> _idempotencyKeys = <String, String>{};

  ReceivedOrdersState state = const ReceivedOrdersState();

  Future<void> loadReceivedOrders() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    notifyListeners();

    try {
      final orders = await _useCase.getReceivedOrders(businessId: _businessId);

      state = state.copyWith(
        orders: List<ReceivedOrderEntity>.unmodifiable(orders),
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل الطلبات المستلمة. حاول مرة أخرى.',
      );
    }

    notifyListeners();
  }

  Future<bool> submitResponse({
    required ReceivedOrderEntity order,
    required List<SubmitReceivedOrderItemResponse> items,
  }) async {
    if (state.isSubmitting) {
      return false;
    }

    if (order.hasResponse) {
      state = state.copyWith(errorMessage: 'تم الرد على هذا الطلب مسبقًا.');
      notifyListeners();
      return false;
    }

    final expectedIds = order.items.map((item) => item.id).toSet();
    final submittedIds = items.map((item) => item.orderRecipientItemId).toSet();

    if (items.length != order.items.length ||
        expectedIds.length != submittedIds.length ||
        !expectedIds.containsAll(submittedIds)) {
      state = state.copyWith(errorMessage: 'يجب إرسال رد لكل عناصر الطلب.');
      notifyListeners();
      return false;
    }

    final validationError = _validateItems(order, items);

    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      notifyListeners();
      return false;
    }

    final recipientId = order.id;

    final idempotencyKey = _idempotencyKeys.putIfAbsent(
      recipientId,
      () => const Uuid().v4(),
    );

    state = state.copyWith(
      submittingRecipientId: recipientId,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final response = await _useCase.submitResponse(
        businessId: _businessId,
        recipientId: recipientId,
        idempotencyKey: idempotencyKey,
        items: items,
      );

      final updatedOrders = state.orders
          .map((current) {
            if (current.id != recipientId) {
              return current;
            }

            return ReceivedOrderEntity(
              id: current.id,
              orderId: current.orderId,
              supplierId: current.supplierId,
              supplierName: current.supplierName,
              orderStatus: current.orderStatus,
              fulfillmentStatus: current.fulfillmentStatus,
              fulfillmentVersion: current.fulfillmentVersion,
              items: current.items,
              notes: current.notes,
              response: response,
              createdAt: current.createdAt,
              updatedAt: current.updatedAt,
            );
          })
          .toList(growable: false);

      _idempotencyKeys.remove(recipientId);

      state = state.copyWith(
        orders: List<ReceivedOrderEntity>.unmodifiable(updatedOrders),
        clearSubmittingRecipientId: true,
        clearErrorMessage: true,
      );

      notifyListeners();
      return true;
    } catch (_) {
      // Keep the same idempotency key for retrying this logical response.
      state = state.copyWith(
        clearSubmittingRecipientId: true,
        errorMessage: 'تعذر إرسال الرد. حاول مرة أخرى.',
      );

      notifyListeners();
      return false;
    }
  }

  Future<bool> updateFulfillment({required ReceivedOrderEntity order}) async {
    if (state.isUpdatingFulfillment) {
      return false;
    }

    final nextStatus = order.nextFulfillmentStatus;

    if (order.fulfillmentStatus == null || !order.hasSelection) {
      state = state.copyWith(
        errorMessage:
            'لا يمكن بدء التنفيذ قبل اختيار العميل لكمية من هذا المورد.',
      );
      notifyListeners();
      return false;
    }

    if (nextStatus == null) {
      state = state.copyWith(errorMessage: 'تم إكمال تنفيذ هذا الطلب بالفعل.');
      notifyListeners();
      return false;
    }

    state = state.copyWith(
      updatingFulfillmentRecipientId: order.id,
      clearErrorMessage: true,
    );
    notifyListeners();

    try {
      final updated = await _useCase.updateFulfillment(
        businessId: _businessId,
        recipientId: order.id,
        expectedVersion: order.fulfillmentVersion,
        status: nextStatus,
      );

      final updatedOrders = state.orders
          .map((current) => current.id == order.id ? updated : current)
          .toList(growable: false);

      state = state.copyWith(
        orders: List<ReceivedOrderEntity>.unmodifiable(updatedOrders),
        clearUpdatingFulfillmentRecipientId: true,
        clearErrorMessage: true,
      );

      notifyListeners();
      return true;
    } on StaleRecipientFulfillmentVersionException {
      try {
        final freshOrders = await _useCase.getReceivedOrders(
          businessId: _businessId,
        );

        state = state.copyWith(
          orders: List<ReceivedOrderEntity>.unmodifiable(freshOrders),
          clearUpdatingFulfillmentRecipientId: true,
          errorMessage:
              'تم تحديث حالة التنفيذ لأن بيانات الطلب تغيرت. راجع الحالة الحالية ثم حاول مجددًا.',
        );
      } catch (_) {
        state = state.copyWith(
          clearUpdatingFulfillmentRecipientId: true,
          errorMessage:
              'تغيرت حالة التنفيذ وتعذر تحميل أحدث البيانات. أعد تحميل الطلبات.',
        );
      }

      notifyListeners();
      return false;
    } catch (_) {
      state = state.copyWith(
        clearUpdatingFulfillmentRecipientId: true,
        errorMessage: 'تعذر تحديث حالة تنفيذ الطلب. حاول مرة أخرى.',
      );

      notifyListeners();
      return false;
    }
  }

  String? _validateItems(
    ReceivedOrderEntity order,
    List<SubmitReceivedOrderItemResponse> responses,
  ) {
    final requestedById = <String, int>{
      for (final item in order.items) item.id: item.requestedQuantity,
    };

    for (final response in responses) {
      final requested = requestedById[response.orderRecipientItemId];

      if (requested == null) {
        return 'يوجد عنصر لا ينتمي إلى هذا الطلب.';
      }

      if (response.availableQuantity < 0 ||
          response.availableQuantity > requested) {
        return 'الكمية المتاحة يجب أن تكون بين 0 والكمية المطلوبة.';
      }

      switch (response.availability) {
        case ReceivedOrderAvailability.full:
          if (response.availableQuantity != requested) {
            return 'حالة متوفر بالكامل تتطلب كامل الكمية المطلوبة.';
          }

        case ReceivedOrderAvailability.partial:
          if (response.availableQuantity <= 0 ||
              response.availableQuantity >= requested) {
            return 'حالة متوفر جزئيًا تتطلب كمية بين 0 والكمية المطلوبة.';
          }

        case ReceivedOrderAvailability.unavailable:
          if (response.availableQuantity != 0) {
            return 'حالة غير متوفر تتطلب كمية متاحة تساوي 0.';
          }
      }

      final offeredPrice = response.offeredUnitPrice;

      if (offeredPrice != null && offeredPrice < 0) {
        return 'السعر المعروض لا يمكن أن يكون سالبًا.';
      }

      if ((response.responseNotes?.length ?? 0) > 2000) {
        return 'ملاحظات الرد يجب ألا تتجاوز 2000 حرف.';
      }
    }

    return null;
  }
}

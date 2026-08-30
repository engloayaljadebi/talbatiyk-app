import 'package:flutter/foundation.dart';

import '../../domain/entities/order_response_comparison_entity.dart';
import '../../domain/errors/stale_order_version_exception.dart';
import '../../domain/usecases/order_response_comparison_usecase.dart';
import '../state/order_response_comparison_state.dart';

final class OrderResponseComparisonController extends ChangeNotifier {
  OrderResponseComparisonController(
    this._orderId,
    this._useCase, {
    bool autoLoad = true,
  }) {
    if (autoLoad) {
      loadComparison();
    }
  }

  final String _orderId;
  final OrderResponseComparisonUseCase _useCase;

  OrderResponseComparisonState state = const OrderResponseComparisonState();

  Future<void> loadComparison() async {
    if (state.isLoading) {
      return;
    }

    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    notifyListeners();

    try {
      final comparison = await _useCase.getComparison(orderId: _orderId);

      state = state.copyWith(
        comparison: comparison,
        isLoading: false,
        clearErrorMessage: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'تعذر تحميل ردود الموردين. حاول مرة أخرى.',
      );
    }

    notifyListeners();
  }

  Future<bool> submitSelections(
    List<OrderResponseSelectionInput> selections,
  ) async {
    if (state.isSubmitting) {
      return false;
    }

    final comparison = state.comparison;

    if (comparison == null) {
      state = state.copyWith(errorMessage: 'يجب تحميل ردود الموردين أولاً.');
      notifyListeners();
      return false;
    }

    final validationError = _validateSelections(comparison, selections);

    if (validationError != null) {
      state = state.copyWith(errorMessage: validationError);
      notifyListeners();
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearErrorMessage: true);
    notifyListeners();

    try {
      final updated = await _useCase.replaceSelections(
        orderId: _orderId,
        expectedVersion: comparison.version,
        selections: selections,
      );

      state = state.copyWith(
        comparison: updated,
        isSubmitting: false,
        clearErrorMessage: true,
      );

      notifyListeners();
      return true;
    } on StaleOrderVersionException {
      try {
        final fresh = await _useCase.getComparison(orderId: _orderId);

        state = state.copyWith(
          comparison: fresh,
          isSubmitting: false,
          errorMessage:
              'تم تحديث الطلب لأن بيانات الاختيار تغيرت. راجع الردود ثم أعد الحفظ.',
        );
      } catch (_) {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage:
              'تغيرت بيانات الطلب وتعذر تحديثها الآن. حاول إعادة التحميل.',
        );
      }

      notifyListeners();
      return false;
    } catch (_) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'تعذر حفظ اختيار المورد. حاول مرة أخرى.',
      );

      notifyListeners();
      return false;
    }
  }

  String? _validateSelections(
    OrderResponseComparisonEntity comparison,
    List<OrderResponseSelectionInput> selections,
  ) {
    if (selections.isEmpty) {
      return 'اختر رد مورد واحداً على الأقل.';
    }

    final itemsByResponseId = <String, OrderResponseComparisonItemEntity>{};

    for (final item in comparison.items) {
      final response = item.response;

      if (response != null) {
        itemsByResponseId[response.id] = item;
      }
    }

    final seenResponseIds = <String>{};
    final totalsByItem = <String, int>{};

    for (final selection in selections) {
      final responseId = selection.orderRecipientItemResponseId.trim();

      if (responseId.isEmpty) {
        return 'معرف رد المورد غير صالح.';
      }

      if (!seenResponseIds.add(responseId)) {
        return 'لا يمكن اختيار رد المورد نفسه أكثر من مرة.';
      }

      if (selection.selectedQuantity <= 0) {
        return 'الكمية المختارة يجب أن تكون أكبر من صفر.';
      }

      final item = itemsByResponseId[responseId];

      if (item == null) {
        return 'أحد الردود المختارة لا ينتمي إلى هذا الطلب.';
      }

      final response = item.response!;

      if (response.availability == OrderResponseAvailability.unavailable) {
        return 'لا يمكن اختيار رد غير متوفر.';
      }

      if (selection.selectedQuantity > response.availableQuantity) {
        return 'الكمية المختارة تتجاوز الكمية المتاحة لدى المورد.';
      }

      final nextTotal =
          (totalsByItem[item.id] ?? 0) + selection.selectedQuantity;

      if (nextTotal > item.requestedQuantity) {
        return 'مجموع الكمية المختارة يتجاوز الكمية المطلوبة.';
      }

      totalsByItem[item.id] = nextTotal;
    }

    return null;
  }
}

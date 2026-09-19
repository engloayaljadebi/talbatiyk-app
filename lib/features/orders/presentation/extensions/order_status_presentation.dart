import 'package:flutter/material.dart';

import '../../domain/entities/orders_entity.dart';

/// Presentation semantics for the server-authoritative aggregate order lifecycle.
extension OrderAggregateStatusPresentation on OrderAggregateStatus {
  String get label {
    switch (this) {
      case OrderAggregateStatus.pendingResponses:
        return 'بانتظار ردود الموردين';
      case OrderAggregateStatus.responsesReceived:
        return 'تم استلام ردود الموردين';
      case OrderAggregateStatus.suppliersSelected:
        return 'تم اختيار الموردين';
      case OrderAggregateStatus.inFulfillment:
        return 'قيد التنفيذ';
      case OrderAggregateStatus.partiallyCompleted:
        return 'مكتمل جزئياً';
      case OrderAggregateStatus.completed:
        return 'مكتمل';
      case OrderAggregateStatus.cancelled:
        return 'ملغاة';
      case OrderAggregateStatus.expired:
        return 'منتهية';
    }
  }

  Color get color {
    switch (this) {
      case OrderAggregateStatus.pendingResponses:
        return Colors.orange;
      case OrderAggregateStatus.responsesReceived:
        return Colors.blue;
      case OrderAggregateStatus.suppliersSelected:
        return Colors.teal;
      case OrderAggregateStatus.inFulfillment:
        return Colors.indigo;
      case OrderAggregateStatus.partiallyCompleted:
        return Colors.purple;
      case OrderAggregateStatus.completed:
        return Colors.green;
      case OrderAggregateStatus.cancelled:
        return Colors.red;
      case OrderAggregateStatus.expired:
        return Colors.grey;
    }
  }

  IconData get icon {
    switch (this) {
      case OrderAggregateStatus.pendingResponses:
        return Icons.schedule_rounded;
      case OrderAggregateStatus.responsesReceived:
        return Icons.mark_email_read_outlined;
      case OrderAggregateStatus.suppliersSelected:
        return Icons.how_to_reg_outlined;
      case OrderAggregateStatus.inFulfillment:
        return Icons.inventory_2_outlined;
      case OrderAggregateStatus.partiallyCompleted:
        return Icons.pending_actions_outlined;
      case OrderAggregateStatus.completed:
        return Icons.check_circle_outline_rounded;
      case OrderAggregateStatus.cancelled:
        return Icons.cancel_outlined;
      case OrderAggregateStatus.expired:
        return Icons.timer_off_outlined;
    }
  }

  int get progressIndex {
    switch (this) {
      case OrderAggregateStatus.pendingResponses:
        return 0;
      case OrderAggregateStatus.responsesReceived:
        return 1;
      case OrderAggregateStatus.suppliersSelected:
        return 2;
      case OrderAggregateStatus.inFulfillment:
        return 3;
      case OrderAggregateStatus.partiallyCompleted:
        return 4;
      case OrderAggregateStatus.completed:
        return 5;
      case OrderAggregateStatus.cancelled:
      case OrderAggregateStatus.expired:
        return -1;
    }
  }

  bool get isTerminalWithoutCompletion {
    return this == OrderAggregateStatus.cancelled ||
        this == OrderAggregateStatus.expired;
  }
}

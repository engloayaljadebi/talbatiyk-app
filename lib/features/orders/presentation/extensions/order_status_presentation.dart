// محتوى الملف:
// - تحويل حالة الطلب إلى اسم عربي.
// - تحديد لون وأيقونة كل حالة.
// - تحديد ترتيب الحالة في مراحل تقدم الطلب.
// - توفير خصائص مشتركة لصفحة الطلبات وصفحة التفاصيل.

import 'package:flutter/material.dart';

import '../../domain/entities/orders_entity.dart';

/// خصائص العرض الخاصة بحالة الطلب.
extension OrderStatusPresentation on OrderStatus {
  /// الاسم العربي للحالة.
  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'قيد المراجعة';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'قيد التجهيز';
      case OrderStatus.readyForDelivery:
        return 'جاهزة للتسليم';
      case OrderStatus.outForDelivery:
        return 'في الطريق';
      case OrderStatus.delivered:
        return 'تم التسليم';
      case OrderStatus.cancelled:
        return 'ملغاة';
    }
  }

  /// اللون الخاص بالحالة.
  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.preparing:
        return Colors.indigo;
      case OrderStatus.readyForDelivery:
        return Colors.teal;
      case OrderStatus.outForDelivery:
        return Colors.purple;
      case OrderStatus.delivered:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  /// الأيقونة المناسبة للحالة.
  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.schedule_rounded;
      case OrderStatus.confirmed:
        return Icons.verified_outlined;
      case OrderStatus.preparing:
        return Icons.inventory_2_outlined;
      case OrderStatus.readyForDelivery:
        return Icons.task_alt_rounded;
      case OrderStatus.outForDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.delivered:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }

  /// رقم المرحلة الحالية داخل مسار الطلب.
  int get progressIndex {
    switch (this) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.preparing:
        return 2;
      case OrderStatus.readyForDelivery:
        return 3;
      case OrderStatus.outForDelivery:
        return 4;
      case OrderStatus.delivered:
        return 5;
      case OrderStatus.cancelled:
        return -1;
    }
  }

  /// هل الطلب ملغى؟
  bool get isCancelled {
    return this == OrderStatus.cancelled;
  }

  /// النص الذي يظهر داخل زر الانتقال للمرحلة التالية.
  String? get nextActionLabel {
    switch (this) {
      case OrderStatus.pending:
        return 'تأكيد الطلبية';
      case OrderStatus.confirmed:
        return 'بدء تجهيز الطلبية';
      case OrderStatus.preparing:
        return 'تحديدها جاهزة للتسليم';
      case OrderStatus.readyForDelivery:
        return 'بدء توصيل الطلبية';
      case OrderStatus.outForDelivery:
        return 'تأكيد استلام الطلبية';
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }

  /// الأيقونة التي تظهر داخل زر المرحلة التالية.
  IconData? get nextActionIcon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.verified_outlined;
      case OrderStatus.confirmed:
        return Icons.inventory_2_outlined;
      case OrderStatus.preparing:
        return Icons.task_alt_rounded;
      case OrderStatus.readyForDelivery:
        return Icons.local_shipping_outlined;
      case OrderStatus.outForDelivery:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.delivered:
      case OrderStatus.cancelled:
        return null;
    }
  }
}

import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';

/// يعرض Feedback واضحًا بعد محاولة إضافة منتج إلى السلة.
void showCartAddResultMessage(
  BuildContext context,
  CartAddResult result, {
  int? quantity,
}) {
  final String message;
  final Color backgroundColor;

  switch (result) {
    case CartAddResult.added:
      message = quantity != null
          ? 'تمت الإضافة إلى السلة — الكمية: $quantity'
          : 'تمت إضافة المنتج إلى السلة';
      backgroundColor = Colors.green.shade700;

    case CartAddResult.unavailable:
      message = 'هذا المنتج غير متوفر حاليًا';
      backgroundColor = Colors.orange.shade800;

    case CartAddResult.differentSupplier:
      // Legacy compatibility فقط؛ Multi-Supplier Cart لا تعيد هذه النتيجة.
      message = 'تعذر إضافة المنتج إلى السلة';
      backgroundColor = Colors.red.shade700;
  }

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
}

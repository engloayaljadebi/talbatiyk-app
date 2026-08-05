import 'package:flutter/material.dart';

import '../controllers/cart_controller.dart';

/// عرض رسالة مناسبة بعد محاولة إضافة منتج إلى السلة.
///
/// لا نعرض رسالة عند نجاح الإضافة حتى لا نزعج المستخدم
/// عند زيادة الكمية عدة مرات.
void showCartAddResultMessage(BuildContext context, CartAddResult result) {
  final String message;
  final Color backgroundColor;

  switch (result) {
    case CartAddResult.added:
      return;

    case CartAddResult.unavailable:
      message = 'هذا المنتج غير متوفر حاليًا';
      backgroundColor = Colors.orange.shade800;

    case CartAddResult.differentSupplier:
      message =
          'لا يمكن إضافة منتجات من مورد مختلف. '
          'أرسل الطلبية الحالية أو أفرغ السلة أولًا.';
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../cart/presentation/utils/cart_feedback.dart';
import '../../../supplier_follow/presentation/providers/supplier_follow_provider.dart';
import '../../domain/entities/products_entity.dart';

/// ينفذ Follow Gate قبل إضافة المنتج إلى السلة.
///
/// القاعدة التجارية:
/// - المورد المتابَع: إضافة مباشرة.
/// - المورد غير المتابَع: Confirmation ثم Follow ثم Add بعد نجاح Follow فقط.
/// - إلغاء أو فشل Follow لا يضيف المنتج.
/// - حالة Follow غير المعروفة لا تنفذ mutation حتى ينتهي تحميلها.
/// - اختلاف المورد لا يمنع الإضافة لأن Cart تدعم Multi-Supplier.
Future<void> addProductWithFollowGate({
  required BuildContext context,
  required WidgetRef ref,
  required ProductEntity product,
  ValueChanged<bool>? onProcessingChanged,
}) async {
  final businessId = product.supplierId.trim();

  // دعم البيانات القديمة والمحلية التي لا تحتوي هوية مورد.
  if (businessId.isEmpty) {
    await _addProduct(context, ref, product);
    return;
  }

  final followController = ref.read(supplierFollowProvider(businessId));

  // لا ننفذ عملية متزامنة فوق تحميل أو تحديث Follow قائم.
  if (followController.isLoading || followController.isUpdating) {
    return;
  }

  // المورد متابَع بالفعل، لذلك لا نحتاج Confirmation أو Network call.
  if (followController.isFollowing == true) {
    await _addProduct(context, ref, product);
    return;
  }

  // نحافظ على سلوك Gate 2.4:
  // لا نخمن الحالة ولا نطلق Follow عندما لم تُحمّل الحالة بعد.
  if (followController.isFollowing == null) {
    return;
  }

  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('متابعة المورد وإضافة المنتج'),
        content: const Text('يجب متابعة المورد قبل إضافة المنتج إلى السلة.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            child: const Text('متابعة وإضافة'),
          ),
        ],
      );
    },
  );

  if (confirmed != true || !context.mounted) {
    return;
  }

  // نبدأ Processing بعد Confirmation فقط.
  // الـDialog نفسه يمنع Double Tap أثناء انتظار قرار المستخدم.
  onProcessingChanged?.call(true);

  try {
    final isFollowing = await followController.toggle();

    if (!context.mounted || !isFollowing) {
      return;
    }

    await _addProduct(context, ref, product);
  } finally {
    if (context.mounted) {
      onProcessingChanged?.call(false);
    }
  }
}

/// ينفذ Cart mutation ويعرض Feedback مع الكمية الجديدة.
Future<void> _addProduct(
  BuildContext context,
  WidgetRef ref,
  ProductEntity product,
) async {
  final cart = ref.read(cartProvider);

  // Cart is local-first. Never mutate it before the persisted snapshot
  // finishes hydrating from Drift, otherwise a startup add could overwrite
  // items restored from the previous session.
  await cart.ready;

  if (!context.mounted) {
    return;
  }

  final result = cart.addProduct(product);

  showCartAddResultMessage(
    context,
    result,
    quantity: cart.quantityOf(product.id),
  );
}

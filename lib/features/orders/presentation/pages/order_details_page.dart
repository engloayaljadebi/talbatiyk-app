// محتوى الملف:
// - عرض رقم الطلب وحالته وتاريخ إنشائه.
// - عرض مسار تقدم الطلب من المراجعة حتى التسليم.
// - تجهيز قسم بيانات المورد للربط بالـ API.
// - عرض منتجات الطلب مع الصور والكميات والأسعار.
// - عرض ملاحظات الطلب إن وجدت.
// - عرض ملخص الكمية والإجمالي النهائي.
//
// الدوال المساعدة:
// - _formatDate: تنسيق تاريخ الطلب.
// - _formatPrice: تنسيق السعر دون أصفار زائدة.
//
// الواجهات الداخلية:
// - _OrderHeaderCard: ملخص الطلب.
// - _OrderProgressCard: مراحل حالة الطلب.
// - _SupplierCard: بيانات المورد.
// - _OrderItemsCard: قائمة المنتجات.
// - _OrderItemTile: منتج واحد.
// - _OrderItemImage: صورة المنتج مع معالجة الفشل.
// - _OrderNotesCard: ملاحظات الطلب.
// - _OrderSummaryCard: الإجمالي النهائي.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/orders_entity.dart';
import '../extensions/order_status_presentation.dart';
import '../providers/orders_provider.dart';
import '../controllers/orders_controller.dart';

/// صفحة التفاصيل الكاملة لطلبية واحدة.
/// صفحة التفاصيل الكاملة لطلبية واحدة.
///
/// تراقب OrdersController حتى تتحدث حالة الطلبية فورًا
/// دون الحاجة إلى إغلاق الصفحة وفتحها مرة أخرى.
class OrderDetailsPage extends ConsumerWidget {
  const OrderDetailsPage({super.key, required this.order});

  /// النسخة الأولية من الطلبية عند فتح الصفحة.
  final OrderEntity order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordersProvider);

    // قراءة النسخة الأحدث من الطلبية الموجودة داخل الحالة.
    final OrderEntity currentOrder =
        controller.findOrderById(order.id) ?? order;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('تفاصيل الطلبية'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          _OrderHeaderCard(order: currentOrder),
          const SizedBox(height: 16),

          _OrderProgressCard(status: currentOrder.status),
          const SizedBox(height: 16),

          _OrderActionsCard(
            order: currentOrder,

            // نقل الطلبية إلى المرحلة التالية.
            onAdvance: () {
              _advanceOrderStatus(
                context: context,
                controller: controller,
                order: currentOrder,
              );
            },

            // إلغاء الطلبية بعد التأكيد.
            onCancel: () {
              _cancelOrder(
                context: context,
                controller: controller,
                order: currentOrder,
              );
            },
          ),
          const SizedBox(height: 16),

          // سيستقبل بيانات المورد الفعلية بعد تحديد استجابة الـ API.
          const _SupplierCard(),
          const SizedBox(height: 16),

          _OrderItemsCard(items: currentOrder.items),

          if (currentOrder.notes.trim().isNotEmpty) ...[
            const SizedBox(height: 16),
            _OrderNotesCard(notes: currentOrder.notes),
          ],

          const SizedBox(height: 16),
          _OrderSummaryCard(order: currentOrder),
        ],
      ),
    );
  }

  /// نقل الطلبية إلى المرحلة التالية بعد موافقة المستخدم.
  Future<void> _advanceOrderStatus({
    required BuildContext context,
    required OrdersController controller,
    required OrderEntity order,
  }) async {
    final OrderStatus? nextStatus = order.status.nextStatus;

    if (nextStatus == null) {
      return;
    }

    final bool confirmed = await _showConfirmationDialog(
      context: context,
      title: 'تحديث حالة الطلبية',
      message:
          'سيتم تغيير حالة الطلبية من '
          '"${order.status.label}" إلى "${nextStatus.label}".',
      confirmLabel: order.status.nextActionLabel ?? 'تحديث الحالة',
      confirmColor: nextStatus.color,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final bool success = await controller.updateOrderStatus(
      orderId: order.id,
      newStatus: nextStatus,
    );

    if (!context.mounted) {
      return;
    }

    _showResultMessage(
      context: context,
      success: success,
      successMessage: 'تم تحديث حالة الطلبية إلى "${nextStatus.label}"',
      errorMessage: controller.state.errorMessage ?? 'تعذر تحديث حالة الطلبية',
    );
  }

  /// إلغاء الطلبية بعد عرض رسالة تحذير.
  Future<void> _cancelOrder({
    required BuildContext context,
    required dynamic controller,
    required OrderEntity order,
  }) async {
    final bool confirmed = await _showConfirmationDialog(
      context: context,
      title: 'إلغاء الطلبية',
      message:
          'هل أنت متأكد من إلغاء الطلبية؟ '
          'لن تتمكن من تغيير حالتها بعد الإلغاء.',
      confirmLabel: 'إلغاء الطلبية',
      confirmColor: AppColors.error,
    );

    if (!confirmed || !context.mounted) {
      return;
    }

    final bool success = await controller.updateOrderStatus(
      orderId: order.id,
      newStatus: OrderStatus.cancelled,
    );

    if (!context.mounted) {
      return;
    }

    _showResultMessage(
      context: context,
      success: success,
      successMessage: 'تم إلغاء الطلبية',
      errorMessage: controller.state.errorMessage ?? 'تعذر إلغاء الطلبية',
    );
  }

  /// عرض نافذة تأكيد قبل تنفيذ تغيير حساس.
  Future<bool> _showConfirmationDialog({
    required BuildContext context,
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          content: Text(
            message,
            style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('تراجع'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: confirmColor,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// إظهار نتيجة عملية تحديث الحالة.
  void _showResultMessage({
    required BuildContext context,
    required bool success,
    required String successMessage,
    required String errorMessage,
  }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(success ? successMessage : errorMessage),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
  }
}

/// بطاقة التحكم في حالة الطلبية.
///
/// تظهر زر المرحلة التالية وزر الإلغاء ما دامت
/// الطلبية لم تصل إلى حالة نهائية.
class _OrderActionsCard extends StatelessWidget {
  const _OrderActionsCard({
    required this.order,
    required this.onAdvance,
    required this.onCancel,
  });

  final OrderEntity order;
  final VoidCallback onAdvance;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final OrderStatus status = order.status;

    if (status.isFinal) {
      return _SectionCard(
        title: 'إدارة الطلبية',
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: status.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(status.icon, color: status.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status == OrderStatus.delivered
                    ? 'اكتملت هذه الطلبية وتم تسليمها بنجاح.'
                    : 'تم إلغاء هذه الطلبية ولا يمكن تغيير حالتها.',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final String? actionLabel = status.nextActionLabel;
    final IconData? actionIcon = status.nextActionIcon;

    return _SectionCard(
      title: 'إدارة الطلبية',
      child: Column(
        children: [
          if (actionLabel != null && actionIcon != null)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onAdvance,
                icon: Icon(actionIcon),
                label: Text(actionLabel),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined),
              label: const Text('إلغاء الطلبية'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة ملخص الطلب في أعلى الصفحة.
class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final OrderStatus status = order.status;

    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'طلبية #${order.id}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  'تاريخ الطلب: ${_formatDate(order.createdAt)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// شارة حالة الطلب.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final OrderStatus status;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(status.icon, size: 16, color: status.color),
            const SizedBox(width: 6),
            Text(
              status.label,
              style: TextStyle(
                color: status.color,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// بطاقة مراحل تقدم الطلب.
class _OrderProgressCard extends StatelessWidget {
  const _OrderProgressCard({required this.status});

  final OrderStatus status;

  static const List<OrderStatus> _trackedStatuses = [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.readyForDelivery,
    OrderStatus.outForDelivery,
    OrderStatus.delivered,
  ];

  @override
  Widget build(BuildContext context) {
    if (status.isCancelled) {
      return Material(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        child: const Padding(
          padding: EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(Icons.cancel_outlined, color: AppColors.error, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'تم إلغاء هذه الطلبية',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return _SectionCard(
      title: 'حالة الطلبية',
      child: Column(
        children: [
          for (int index = 0; index < _trackedStatuses.length; index++)
            _ProgressStep(
              status: _trackedStatuses[index],
              isCompleted: index <= status.progressIndex,
              isCurrent: index == status.progressIndex,
              showLine: index < _trackedStatuses.length - 1,
            ),
        ],
      ),
    );
  }
}

/// مرحلة واحدة داخل مسار الطلب.
class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.status,
    required this.isCompleted,
    required this.isCurrent,
    required this.showLine,
  });

  final OrderStatus status;
  final bool isCompleted;
  final bool isCurrent;
  final bool showLine;

  @override
  Widget build(BuildContext context) {
    final Color stepColor = isCompleted ? status.color : AppColors.disabled;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCompleted ? stepColor : AppColors.background,
                    shape: BoxShape.circle,
                    border: Border.all(color: stepColor, width: 2),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : status.icon,
                    size: 16,
                    color: isCompleted ? Colors.white : AppColors.textHint,
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isCompleted
                          ? stepColor.withValues(alpha: 0.45)
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 3, bottom: showLine ? 18 : 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      status.label,
                      style: TextStyle(
                        color: isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                        fontWeight: isCurrent
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Text(
                      'الحالة الحالية',
                      style: TextStyle(
                        color: status.color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// قسم بيانات المورد.
///
/// البيانات غير موجودة حاليًا داخل OrderEntity، لذلك لا نعرض
/// بيانات افتراضية قد تكون غير صحيحة.
class _SupplierCard extends StatelessWidget {
  const _SupplierCard();

  @override
  Widget build(BuildContext context) {
    return const _SectionCard(
      title: 'بيانات المورد',
      child: Row(
        children: [
          _SectionIcon(icon: Icons.storefront_outlined),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'ستظهر بيانات المورد هنا بعد ربط الطلبية بالمورد عبر الـ API',
              style: TextStyle(color: AppColors.textSecondary, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// بطاقة قائمة منتجات الطلبية.
class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'المنتجات (${items.length})',
      child: Column(
        children: [
          for (int index = 0; index < items.length; index++) ...[
            _OrderItemTile(item: items[index]),
            if (index < items.length - 1)
              const Divider(height: 25, color: AppColors.border),
          ],
        ],
      ),
    );
  }
}

/// صف منتج واحد داخل الطلبية.
class _OrderItemTile extends StatelessWidget {
  const _OrderItemTile({required this.item});

  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrderItemImage(imageUrl: item.imageUrl),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'الكمية: ${item.quantity}',
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                'سعر الوحدة: ${_formatPrice(item.unitPrice)} ر.ي',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${_formatPrice(item.totalPrice)} ر.ي',
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// صورة المنتج مع واجهة بديلة عند غياب الصورة أو فشل تحميلها.
class _OrderItemImage extends StatelessWidget {
  const _OrderItemImage({required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final String normalizedUrl = imageUrl.trim();

    if (normalizedUrl.isEmpty) {
      return const _ProductImagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        normalizedUrl,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const _ProductImagePlaceholder();
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return const SizedBox(
            width: 64,
            height: 64,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// واجهة بديلة لصورة المنتج.
class _ProductImagePlaceholder extends StatelessWidget {
  const _ProductImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: AppColors.textHint),
    );
  }
}

/// بطاقة ملاحظات المستخدم على الطلبية.
class _OrderNotesCard extends StatelessWidget {
  const _OrderNotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ملاحظات الطلب',
      child: Text(
        notes.trim(),
        style: const TextStyle(color: AppColors.textSecondary, height: 1.6),
      ),
    );
  }
}

/// بطاقة ملخص الكمية والإجمالي.
class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ملخص الطلبية',
      child: Column(
        children: [
          _SummaryRow(label: 'إجمالي الكمية', value: '${order.totalQuantity}'),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 12),
          _SummaryRow(
            label: 'الإجمالي النهائي',
            value: '${_formatPrice(order.totalPrice)} ر.ي',
            emphasize: true,
          ),
        ],
      ),
    );
  }
}

/// صف واحد داخل ملخص الطلب.
class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: emphasize ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: emphasize ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            color: emphasize ? AppColors.primary : AppColors.textPrimary,
            fontSize: emphasize ? 17 : 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

/// بطاقة موحدة لأقسام صفحة التفاصيل.
class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// أيقونة موحدة داخل الأقسام.
class _SectionIcon extends StatelessWidget {
  const _SectionIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }
}

/// تنسيق تاريخ الطلب بصيغة يوم/شهر/سنة.
String _formatDate(DateTime date) {
  final DateTime localDate = date.toLocal();

  return '${localDate.day}/${localDate.month}/${localDate.year}';
}

/// تنسيق السعر مع حذف المنازل العشرية غير الضرورية.
String _formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    return price.toStringAsFixed(0);
  }

  return price.toStringAsFixed(2);
}

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
import '../../../order_response_comparison/presentation/pages/order_response_comparison_page.dart';
import '../../domain/entities/orders_entity.dart';
import '../extensions/order_status_presentation.dart';
import '../providers/orders_provider.dart';

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

          _OrderProgressCard(status: currentOrder.aggregateStatus),
          const SizedBox(height: 16),

          _SupplierResponsesCard(
            onOpen: () async {
              await Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                      OrderResponseComparisonPage(orderId: currentOrder.id),
                ),
              );

              if (!context.mounted) {
                return;
              }

              await controller.loadOrders();
            },
          ),
          const SizedBox(height: 16),

          _SupplierCard(supplier: currentOrder.supplier),
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
}

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final OrderAggregateStatus status = order.aggregateStatus;

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

  final OrderAggregateStatus status;

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

  final OrderAggregateStatus status;

  static const List<OrderAggregateStatus> _trackedStatuses = [
    OrderAggregateStatus.pendingResponses,
    OrderAggregateStatus.responsesReceived,
    OrderAggregateStatus.suppliersSelected,
    OrderAggregateStatus.inFulfillment,
    OrderAggregateStatus.partiallyCompleted,
    OrderAggregateStatus.completed,
  ];

  @override
  Widget build(BuildContext context) {
    if (status.isTerminalWithoutCompletion) {
      return _SectionCard(
        title: 'حالة الطلبية',
        child: Row(
          children: [
            Icon(status.icon, color: status.color, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                status == OrderAggregateStatus.cancelled
                    ? 'تم إلغاء هذه الطلبية.'
                    : 'انتهت صلاحية هذه الطلبية.',
                style: TextStyle(
                  color: status.color,
                  fontWeight: FontWeight.w800,
                  height: 1.5,
                ),
              ),
            ),
          ],
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

  final OrderAggregateStatus status;
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
/// بطاقة بيانات المورد المرتبط بالطلبية.
///
/// تعرض الاسم والمعرّف المحفوظين وقت إنشاء الطلبية.
/// البيانات قد تكون غير موجودة في الطلبيات القديمة.
class _SupplierResponsesCard extends StatelessWidget {
  const _SupplierResponsesCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ردود الموردين',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'راجع الكميات المتاحة والأسعار المعروضة من الموردين المرتبطين بعناصر الطلب، ثم حدد الكميات المقبولة.',
            style: TextStyle(color: AppColors.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              key: const Key('open-supplier-responses'),
              onPressed: onOpen,
              icon: const Icon(Icons.compare_arrows_rounded),
              label: const Text('عرض ردود الموردين'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(48),
                side: const BorderSide(color: AppColors.primary),
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

class _SupplierCard extends StatelessWidget {
  const _SupplierCard({required this.supplier});

  final OrderSupplierEntity? supplier;

  @override
  Widget build(BuildContext context) {
    final String supplierName = supplier?.name.trim() ?? '';

    final String supplierId = supplier?.id.trim() ?? '';

    final bool hasSupplierData = supplier?.hasData ?? false;

    return _SectionCard(
      title: 'بيانات المورد',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionIcon(icon: Icons.storefront_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: hasSupplierData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplierName.isNotEmpty
                            ? supplierName
                            : 'مورد غير مسمى',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (supplierId.isNotEmpty) ...[
                        const SizedBox(height: 7),
                        Text(
                          'معرّف المورد: $supplierId',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  )
                : const Text(
                    'بيانات المورد غير متوفرة لهذه الطلبية',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
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

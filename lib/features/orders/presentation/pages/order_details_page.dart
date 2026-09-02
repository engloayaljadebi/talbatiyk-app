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
    final colors = Theme.of(context).colorScheme;

    // قراءة النسخة الأحدث من الطلبية الموجودة داخل الحالة.
    final OrderEntity currentOrder =
        controller.findOrderById(order.id) ?? order;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('تفاصيل الطلبية'),
        centerTitle: true,
        backgroundColor: colors.surfaceContainerLowest,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final horizontalPadding = constraints.maxWidth >= 760 ? 24.0 : 16.0;

          return ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              8,
              horizontalPadding,
              40,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _OrderHeaderCard(order: currentOrder),
                      const SizedBox(height: 14),

                      _OrderProgressCard(status: currentOrder.aggregateStatus),
                      const SizedBox(height: 14),

                      _SupplierResponsesCard(
                        onOpen: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => OrderResponseComparisonPage(
                                orderId: currentOrder.id,
                              ),
                            ),
                          );

                          if (!context.mounted) {
                            return;
                          }

                          await controller.loadOrders();
                        },
                      ),
                      const SizedBox(height: 14),

                      _SupplierCard(supplier: currentOrder.supplier),
                      const SizedBox(height: 14),

                      _OrderItemsCard(items: currentOrder.items),

                      if (currentOrder.notes.trim().isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _OrderNotesCard(notes: currentOrder.notes),
                      ],

                      const SizedBox(height: 14),
                      _OrderSummaryCard(order: currentOrder),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderHeaderCard extends StatelessWidget {
  const _OrderHeaderCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final OrderAggregateStatus status = order.aggregateStatus;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'طلبية #${_shortOrderId(order.id)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        order.id,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _StatusBadge(status: status),
              ],
            ),
            const SizedBox(height: 18),
            Divider(
              height: 1,
              thickness: 1,
              color: colors.outlineVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 16,
                  color: colors.onSurfaceVariant,
                ),
                const SizedBox(width: 7),
                Text(
                  'تاريخ الطلب',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  _formatDate(order.createdAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
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
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: status.color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            status.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: status.color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
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
    final theme = Theme.of(context);
    if (status.isTerminalWithoutCompletion) {
      return _SectionCard(
        title: 'حالة الطلبية',
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: status.color.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(status.icon, color: status.color, size: 22),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  status == OrderAggregateStatus.cancelled
                      ? 'تم إلغاء هذه الطلبية.'
                      : 'انتهت صلاحية هذه الطلبية.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final int currentIndex = _normalizedProgressIndex(status.progressIndex);

    return _SectionCard(
      title: 'مسار الطلبية',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CurrentStatusSummary(
            status: status,
            currentIndex: currentIndex,
            totalSteps: _trackedStatuses.length,
          ),
          const SizedBox(height: 20),

          for (int index = 0; index < _trackedStatuses.length; index++)
            _ProgressStep(
              status: _trackedStatuses[index],
              isCompleted: index <= currentIndex,
              isCurrent: index == currentIndex,
              showLine: index < _trackedStatuses.length - 1,
              lineCompleted: index < currentIndex,
            ),
        ],
      ),
    );
  }

  int _normalizedProgressIndex(int progressIndex) {
    if (progressIndex < 0) {
      return 0;
    }

    if (progressIndex >= _trackedStatuses.length) {
      return _trackedStatuses.length - 1;
    }

    return progressIndex;
  }
}

class _CurrentStatusSummary extends StatelessWidget {
  const _CurrentStatusSummary({
    required this.status,
    required this.currentIndex,
    required this.totalSteps,
  });

  final OrderAggregateStatus status;
  final int currentIndex;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(17),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  status.label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${currentIndex + 1} من $totalSteps',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            _statusDescription(status),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
            ),
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
    required this.lineCompleted,
  });

  final OrderAggregateStatus status;
  final bool isCompleted;
  final bool isCurrent;
  final bool showLine;
  final bool lineCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Color activeColor = colors.primary;
    final Color inactiveColor = colors.outlineVariant.withValues(alpha: 0.9);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 30,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? activeColor
                        : colors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted ? activeColor : inactiveColor,
                    ),
                  ),
                  child: Icon(
                    isCurrent
                        ? status.icon
                        : isCompleted
                        ? Icons.check_rounded
                        : Icons.circle_outlined,
                    size: 13,
                    color: isCompleted
                        ? colors.onPrimary
                        : colors.onSurfaceVariant,
                  ),
                ),
                if (showLine)
                  Expanded(
                    child: Container(
                      width: 1.5,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: lineCompleted ? activeColor : inactiveColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 2, bottom: showLine ? 17 : 2),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      status.label,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isCompleted
                            ? colors.onSurface
                            : colors.onSurfaceVariant,
                        fontWeight: isCurrent
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                    ),
                  ),
                  if (isCurrent)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'الآن',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w700,
                        ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _SectionCard(
      title: 'ردود الموردين',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'راجع الكميات المتاحة والأسعار التي أرسلها الموردون، ثم اختر العرض المناسب لك.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton(
              key: const Key('open-supplier-responses'),
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w700),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.compare_arrows_rounded, size: 19),
                  SizedBox(width: 8),
                  Text('عرض ردود الموردين'),
                ],
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final String supplierName = supplier?.name.trim() ?? '';

    final String supplierId = supplier?.id.trim() ?? '';

    final bool hasSupplierData = supplier?.hasData ?? false;

    return _SectionCard(
      title: 'بيانات المورد',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionIcon(icon: Icons.storefront_rounded),
          const SizedBox(width: 13),
          Expanded(
            child: hasSupplierData
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        supplierName.isNotEmpty
                            ? supplierName
                            : 'مورد غير مسمى',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (supplierId.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          supplierId,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: TextDirection.ltr,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  )
                : Text(
                    'بيانات المورد غير متوفرة لهذه الطلبية',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
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
    final colors = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'المنتجات (${items.length})',
      child: Column(
        children: [
          for (int index = 0; index < items.length; index++) ...[
            _OrderItemTile(item: items[index]),
            if (index < items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _OrderItemImage(imageUrl: item.imageUrl),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'الكمية: ${item.quantity}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'سعر الوحدة: ${_formatPrice(item.unitPrice)} ر.ي',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                '${_formatPrice(item.totalPrice)} ر.ي',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
    final colors = Theme.of(context).colorScheme;

    if (normalizedUrl.isEmpty) {
      return const _ProductImagePlaceholder();
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.network(
        normalizedUrl,
        width: 68,
        height: 68,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return const _ProductImagePlaceholder();
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) {
            return child;
          }

          return SizedBox(
            width: 68,
            height: 68,
            child: Center(
              child: SizedBox(
                width: 19,
                height: 19,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colors.primary,
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        Icons.inventory_2_outlined,
        size: 26,
        color: colors.onSurfaceVariant,
      ),
    );
  }
}

/// بطاقة ملاحظات المستخدم على الطلبية.
class _OrderNotesCard extends StatelessWidget {
  const _OrderNotesCard({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return _SectionCard(
      title: 'ملاحظات الطلب',
      child: Text(
        notes.trim(),
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colors.onSurfaceVariant,
          height: 1.65,
        ),
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
    final colors = Theme.of(context).colorScheme;

    return _SectionCard(
      title: 'ملخص الطلبية',
      child: Column(
        children: [
          _SummaryRow(label: 'إجمالي الكمية', value: '${order.totalQuantity}'),
          const SizedBox(height: 14),
          Divider(
            height: 1,
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 14),
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: emphasize ? colors.onSurface : colors.onSurfaceVariant,
            fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: emphasize
              ? theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                )
              : theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.55),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.15,
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
    final colors = Theme.of(context).colorScheme;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Icon(icon, size: 21, color: colors.onSurfaceVariant),
    );
  }
}

/// وصف مختصر للحالة الحالية لعرض المعلومة بسرعة.
String _statusDescription(OrderAggregateStatus status) {
  return switch (status) {
    OrderAggregateStatus.pendingResponses =>
      'تم إرسال الطلبية للموردين، وبانتظار وصول ردودهم.',
    OrderAggregateStatus.responsesReceived =>
      'وصلت ردود الموردين ويمكنك الآن مراجعتها ومقارنتها.',
    OrderAggregateStatus.suppliersSelected =>
      'تم اختيار العرض المناسب وأصبحت الطلبية جاهزة للتنفيذ.',
    OrderAggregateStatus.inFulfillment =>
      'المورد يعمل حاليًا على تجهيز وتنفيذ الطلبية.',
    OrderAggregateStatus.partiallyCompleted =>
      'اكتمل جزء من تنفيذ الطلبية وما زال جزء آخر قيد التنفيذ.',
    OrderAggregateStatus.completed => 'اكتمل تنفيذ الطلبية بنجاح.',
    OrderAggregateStatus.cancelled => 'تم إلغاء الطلبية.',
    OrderAggregateStatus.expired => 'انتهت صلاحية الطلبية.',
  };
}

/// إظهار جزء قصير من المعرّف بدل عرض UUID كامل كعنوان.
String _shortOrderId(String id) {
  final String normalizedId = id.trim();

  if (normalizedId.length <= 8) {
    return normalizedId;
  }

  return normalizedId.substring(normalizedId.length - 7);
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

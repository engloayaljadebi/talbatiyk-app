import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/received_order_entity.dart';
import '../controllers/received_orders_controller.dart';
import '../providers/received_orders_provider.dart';

const double _pageMaxWidth = 760;
const double _pagePadding = 16;
const double _cardRadius = 20;
const double _innerRadius = 14;
const double _controlHeight = 52;

// Theme-derived canvas and card colors aligned with the project's ColorScheme.
Color _ordersCanvasColor(BuildContext context) {
  return Theme.of(context).colorScheme.surfaceContainerLowest;
}

Color _ordersCardColor(BuildContext context) {
  return Theme.of(context).colorScheme.surface;
}

// Soft, theme-aware card shadow that works in both light and dark mode.
List<BoxShadow> _cardShadow(BuildContext context) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  return [
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.45 : 0.09),
      blurRadius: 28,
      offset: const Offset(0, 10),
    ),
    BoxShadow(
      color: theme.colorScheme.shadow.withValues(alpha: isDark ? 0.3 : 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
}

// Subtle status accent shown at the top edge of each order card.
Color _statusAccentColor(BuildContext context, ReceivedOrderEntity order) {
  final colors = Theme.of(context).colorScheme;
  if (!order.hasResponse) {
    return colors.onSurfaceVariant;
  }
  if (!order.hasSelection) {
    return colors.tertiary;
  }
  final status = order.fulfillmentStatus;
  if (status == null) {
    return colors.primary;
  }
  if (status == ReceivedOrderFulfillmentStatus.delivered) {
    return colors.primary;
  }
  return colors.primary;
}

final class ReceivedOrdersPage extends ConsumerWidget {
  const ReceivedOrdersPage({
    required this.businessId,
    this.embedded = false,
    super.key,
  });

  final String businessId;
  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(receivedOrdersControllerProvider(businessId));
    final state = controller.state;
    final canvasColor = _ordersCanvasColor(context);

    final content = SafeArea(
      top: false,
      child: Column(
        children: [
          if (state.errorMessage != null && state.orders.isNotEmpty)
            _InlineErrorBanner(
              message: state.errorMessage!,
              onRetry: controller.loadReceivedOrders,
            ),
          Expanded(child: _buildBody(context, controller, state)),
        ],
      ),
    );

    if (embedded) {
      return ColoredBox(color: canvasColor, child: content);
    }
    return Scaffold(
      backgroundColor: canvasColor,
      appBar: AppBar(
        backgroundColor: canvasColor,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          'الطلبات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
        actions: [
          _QuietIconButton(
            tooltip: 'تحديث الطلبات',
            onPressed: state.isLoading ? null : controller.loadReceivedOrders,
            child: state.isLoading && state.orders.isNotEmpty
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded, size: 21),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: content,
    );
  }

  Widget _buildBody(
    BuildContext context,
    ReceivedOrdersController controller,
    dynamic state,
  ) {
    if (state.isLoading && state.orders.isEmpty) {
      return const _LoadingState();
    }

    if (state.errorMessage != null && state.orders.isEmpty) {
      return _Message(
        icon: Icons.wifi_off_rounded,
        title: 'تعذر تحميل الطلبات',
        description: state.errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onPressed: controller.loadReceivedOrders,
      );
    }

    if (state.orders.isEmpty) {
      return _Message(
        icon: Icons.inventory_2_outlined,
        title: 'لا توجد طلبات الآن',
        description: 'عند وصول طلب جديد سيظهر هنا مباشرة.',
        actionLabel: 'تحديث',
        onPressed: controller.loadReceivedOrders,
      );
    }

    return RefreshIndicator.adaptive(
      onRefresh: controller.loadReceivedOrders,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(_pagePadding, 16, _pagePadding, 36),
        itemCount: state.orders.length + 1,
        // Distinguish orders with whitespace, not lines or borders.
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 18 : 24),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: _pageMaxWidth),
                child: const _PageHeading(),
              ),
            );
          }

          final order = state.orders[index - 1] as ReceivedOrderEntity;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _pageMaxWidth),
              child: _ReceivedOrderCard(
                order: order,
                isSubmitting: state.isSubmittingRecipient(order.id),
                isUpdatingFulfillment: state.isUpdatingFulfillmentRecipient(
                  order.id,
                ),
                onRespond: order.hasResponse
                    ? null
                    : () => _openResponseEditor(context, controller, order),
                onAdvanceFulfillment: order.nextFulfillmentStatus == null
                    ? null
                    : () => _advanceFulfillment(context, controller, order),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _advanceFulfillment(
    BuildContext context,
    ReceivedOrdersController controller,
    ReceivedOrderEntity order,
  ) async {
    final succeeded = await controller.updateFulfillment(order: order);

    if (!context.mounted) {
      return;
    }

    if (succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم تحديث حالة الطلب.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  Future<void> _openResponseEditor(
    BuildContext context,
    ReceivedOrdersController controller,
    ReceivedOrderEntity order,
  ) async {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final List<SubmitReceivedOrderItemResponse>? responses;

    if (screenWidth < 700) {
      responses =
          await showModalBottomSheet<List<SubmitReceivedOrderItemResponse>>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _ResponseSheet(order: order),
          );
    } else {
      responses = await showDialog<List<SubmitReceivedOrderItemResponse>>(
        context: context,
        builder: (_) => _ResponseDialog(order: order),
      );
    }

    if (responses == null || !context.mounted) {
      return;
    }

    final succeeded = await controller.submitResponse(
      order: order,
      items: responses,
    );

    if (!context.mounted) {
      return;
    }

    if (succeeded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم إرسال الرد بنجاح.'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }
}

final class _PageHeading extends StatelessWidget {
  const _PageHeading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 21,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'الطلبات المستلمة',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: Text(
              'اعرف الحالة الحالية واتخذ الإجراء التالي بدون تشتيت.',
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

final class _ReceivedOrderCard extends StatelessWidget {
  const _ReceivedOrderCard({
    required this.order,
    required this.isSubmitting,
    required this.isUpdatingFulfillment,
    required this.onRespond,
    required this.onAdvanceFulfillment,
  });

  final ReceivedOrderEntity order;
  final bool isSubmitting;
  final bool isUpdatingFulfillment;
  final VoidCallback? onRespond;
  final VoidCallback? onAdvanceFulfillment;

  @override
  Widget build(BuildContext context) {
    final accent = _statusAccentColor(context, order);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _ordersCardColor(context),
        borderRadius: BorderRadius.circular(_cardRadius),
        boxShadow: _cardShadow(context),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thin colored accent that reflects the order's current stage.
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accent, accent.withValues(alpha: 0.25)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OrderHeader(order: order),
                  const SizedBox(height: 14),
                  _OrderSummary(order: order),
                  if (order.fulfillmentStatus != null) ...[
                    const SizedBox(height: 16),
                    _FulfillmentProgress(status: order.fulfillmentStatus!),
                  ],
                ],
              ),
            ),
            _OrderItemsSection(order: order),
            if (order.notes?.trim().isNotEmpty ?? false)
              _OrderNotes(notes: order.notes!.trim()),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: _OrderActions(
                order: order,
                isSubmitting: isSubmitting,
                isUpdatingFulfillment: isUpdatingFulfillment,
                onRespond: onRespond,
                onAdvanceFulfillment: onAdvanceFulfillment,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _OrderHeader extends StatelessWidget {
  const _OrderHeader({required this.order});

  final ReceivedOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طلب #${_shortOrderId(order.orderId)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.event_outlined,
                      size: 14,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'تاريخ الطلب: ${order.createdAt == null ? 'غير متوفر' : _formatReceivedOrderDate(order.createdAt!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _ResponseStatus(status: order.hasResponse),
      ],
    );
  }
}

final class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final ReceivedOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final hasMeta =
        order.fulfillmentStatus != null ||
        (order.hasResponse && !order.hasSelection);
    if (!hasMeta) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (order.fulfillmentStatus != null)
          _MetaChip(
            icon: Icons.local_shipping_outlined,
            text: order.fulfillmentStatus!.displayLabel,
            emphasized: true,
          ),
        if (order.hasResponse && !order.hasSelection)
          _MetaChip(
            icon: Icons.person_search_outlined,
            text: 'بانتظار اختيار العميل',
          ),
      ],
    );
  }
}

// Compact information chip used for order meta values.
final class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.text,
    this.emphasized = false,
  });

  final IconData icon;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: emphasized
            ? colors.primary.withValues(alpha: 0.09)
            : colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: emphasized ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(
              color: emphasized ? colors.onSurface : colors.onSurfaceVariant,
              fontWeight: emphasized ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

final class _ResponseStatus extends StatelessWidget {
  const _ResponseStatus({required this.status});

  final bool status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status
            ? colors.primary.withValues(alpha: 0.1)
            : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status ? Icons.check_rounded : Icons.schedule_rounded,
            size: 15,
            color: status ? colors.primary : colors.onSurfaceVariant,
          ),
          const SizedBox(width: 6),
          Text(
            status ? 'تم الرد' : 'بانتظار الرد',
            style: theme.textTheme.labelMedium?.copyWith(
              color: status ? colors.primary : colors.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// A numbered step tracker with connectors; completed steps show a check.
final class _FulfillmentProgress extends StatelessWidget {
  const _FulfillmentProgress({required this.status});

  final ReceivedOrderFulfillmentStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final currentStep = status.progressStep;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_innerRadius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  status.displayLabel,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${currentStep + 1} من 5',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              for (var index = 0; index < 5; index++) ...[
                _StepDot(index: index, currentStep: currentStep),
                if (index < 4)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutCubic,
                        height: 3,
                        decoration: BoxDecoration(
                          color: index < currentStep
                              ? colors.primary
                              : colors.onSurface.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
          const SizedBox(height: 11),
          Text(
            status.progressDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}

final class _StepDot extends StatelessWidget {
  const _StepDot({required this.index, required this.currentStep});

  final int index;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final passed = index <= currentStep;
    final isCurrent = index == currentStep;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      width: isCurrent ? 28 : 24,
      height: isCurrent ? 28 : 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: passed ? colors.primary : colors.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: passed ? colors.primary : colors.outlineVariant,
          width: 1.4,
        ),
        boxShadow: isCurrent
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: passed
          ? (index < currentStep
                ? Icon(Icons.check_rounded, size: 14, color: colors.onPrimary)
                : Text(
                    '${index + 1}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: colors.onPrimary,
                    ),
                  ))
          : Text(
              '${index + 1}',
              style: theme.textTheme.labelMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.onSurfaceVariant,
              ),
            ),
    );
  }
}

// Read prices only when they are plain, non-negative numeric values.
// An absent/invalid price must never silently become zero in totals.
num? _parseReceivedOrderPrice(String? raw) {
  final value = raw?.trim() ?? '';
  if (!RegExp(r'^\d+(?:\.\d+)?$').hasMatch(value)) return null;
  return num.tryParse(value);
}

String _formatReceivedOrderAmount(num amount) {
  final fixed = amount.toStringAsFixed(2);
  return fixed.endsWith('.00') ? fixed.substring(0, fixed.length - 3) : fixed;
}

String _receivedOrderPriceText(String? offeredPrice, String originalPrice) {
  final offer = offeredPrice?.trim() ?? '';
  return offer.isNotEmpty ? offer : originalPrice.trim();
}

String _formatReceivedOrderDate(DateTime date) {
  final local = date.toLocal();
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year}  '
      '${two(local.hour)}:${two(local.minute)}';
}

final class _OrderItemsSection extends StatelessWidget {
  const _OrderItemsSection({required this.order});

  final ReceivedOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final selected = _hasRecordedItemSelection(order);

    var quantityTotal = 0;
    num calculatedAmount = 0;
    var missingPrice = false;
    for (final item in order.items) {
      final quantity = _orderDisplayQuantity(order, item);
      quantityTotal += quantity;
      if (quantity == 0) continue;

      final unitPrice = _parseReceivedOrderPrice(
        _receivedOrderPriceText(
          _orderOfferedPrice(order, item),
          item.unitPrice,
        ),
      );
      if (unitPrice == null) {
        missingPrice = true;
      } else {
        calculatedAmount += unitPrice * quantity;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 6, 18, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: colors.primary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'أصناف الطلب',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (order.items.length > 1)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'مرّر لعرض البقية',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.swipe_rounded,
                      size: 16,
                      color: colors.onSurfaceVariant,
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 152,
            child: ListView.separated(
              key: const ValueKey<String>('received-order-items-horizontal'),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: order.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return _OrderItemRow(
                  item: item,
                  quantity: _orderDisplayQuantity(order, item),
                  offeredUnitPrice: _orderOfferedPrice(order, item),
                  selected: selected,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _OrderTotalMetric(
                      label: 'إجمالي الأصناف',
                      value: '${order.items.length}',
                    ),
                    _OrderTotalMetric(
                      label: selected ? 'الكمية المختارة' : 'إجمالي الكمية',
                      value: '$quantityTotal',
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  child: Container(
                    height: 1,
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        selected
                            ? 'إجمالي المبلغ (للكميات المختارة)'
                            : 'إجمالي المبلغ (تقديري)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        missingPrice
                            ? 'غير مكتمل — أسعار ناقصة'
                            : _formatReceivedOrderAmount(calculatedAmount),
                        textAlign: TextAlign.end,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: missingPrice
                              ? colors.onSurfaceVariant
                              : colors.primary,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

bool _hasRecordedItemSelection(ReceivedOrderEntity order) =>
    order.items.any((item) => item.selectedQuantity != null);

int _orderDisplayQuantity(
  ReceivedOrderEntity order,
  ReceivedOrderItemEntity item,
) {
  // Selection may be recorded as zero units; don't mistake it for a new order.
  return _hasRecordedItemSelection(order)
      ? (item.selectedQuantity ?? 0)
      : item.requestedQuantity;
}

String? _orderOfferedPrice(
  ReceivedOrderEntity order,
  ReceivedOrderItemEntity item,
) {
  for (final responseItem
      in order.response?.items ?? const <ReceivedOrderItemResponseEntity>[]) {
    if (responseItem.orderRecipientItemId == item.id) {
      return responseItem.offeredUnitPrice;
    }
  }
  return null;
}

final class _OrderTotalMetric extends StatelessWidget {
  const _OrderTotalMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// Horizontal item preview inside a soft tile: image + name + quantity + price.
final class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({
    required this.item,
    required this.quantity,
    required this.selected,
    this.offeredUnitPrice,
  });

  final ReceivedOrderItemEntity item;
  final int quantity;
  final bool selected;
  final String? offeredUnitPrice;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final priceText = _receivedOrderPriceText(offeredUnitPrice, item.unitPrice);
    final amount = _parseReceivedOrderPrice(priceText);
    final subtotal = amount == null ? null : amount * quantity;

    return Container(
      width: 296,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _OrderProductThumbnail(imageUrl: item.imageUrl, size: 72),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${selected ? 'الكمية المختارة' : 'الكمية'}: $quantity',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سعر الوحدة: ${priceText.isEmpty ? 'غير محدد' : priceText}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.09),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    'الإجمالي: ${subtotal == null ? 'غير محدد' : _formatReceivedOrderAmount(subtotal)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colors.primary,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _OrderProductThumbnail extends StatelessWidget {
  const _OrderProductThumbnail({required this.imageUrl, this.size = 60});

  final String? imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final url = imageUrl?.trim() ?? '';
    final isHttpUrl = url.startsWith('https://') || url.startsWith('http://');
    final fallback = Center(
      child: Icon(
        Icons.image_outlined,
        color: colors.onSurfaceVariant.withValues(alpha: 0.58),
        size: 24,
      ),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: size,
        height: size,
        child: ColoredBox(
          color: colors.surfaceContainerHigh,
          child: isHttpUrl
              ? Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                )
              : fallback,
        ),
      ),
    );
  }
}

final class _OrderNotes extends StatelessWidget {
  const _OrderNotes({required this.notes});

  final String notes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 0, 18, 14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.tertiary.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(_innerRadius),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.notes_rounded, size: 18, color: colors.onSurfaceVariant),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                notes,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

final class _OrderActions extends StatelessWidget {
  const _OrderActions({
    required this.order,
    required this.isSubmitting,
    required this.isUpdatingFulfillment,
    required this.onRespond,
    required this.onAdvanceFulfillment,
  });

  final ReceivedOrderEntity order;
  final bool isSubmitting;
  final bool isUpdatingFulfillment;
  final VoidCallback? onRespond;
  final VoidCallback? onAdvanceFulfillment;

  @override
  Widget build(BuildContext context) {
    if (!order.hasResponse) {
      return _PrimaryActionButton(
        onPressed: isSubmitting ? null : onRespond,
        icon: Icons.arrow_upward_rounded,
        loading: isSubmitting,
        label: isSubmitting ? 'جارٍ إرسال الرد...' : 'الرد على الطلب',
      );
    }

    if (!order.hasSelection) {
      return const _QuietState(
        icon: Icons.hourglass_top_rounded,
        title: 'تم إرسال ردك',
        message: 'بانتظار اختيار العميل. لا تحتاج إلى أي إجراء الآن.',
      );
    }

    if (order.fulfillmentStatus == ReceivedOrderFulfillmentStatus.delivered) {
      return const _QuietState(
        icon: Icons.check_circle_rounded,
        title: 'اكتمل الطلب',
        message: 'تم تسجيل الطلب كمُسلّم بنجاح.',
      );
    }

    if (order.fulfillmentStatus != null &&
        order.nextFulfillmentStatus != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 2, bottom: 9),
            child: Row(
              children: [
                Text(
                  'الإجراء التالي',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_downward_rounded,
                  size: 14,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          _PrimaryActionButton(
            onPressed: isUpdatingFulfillment ? null : onAdvanceFulfillment,
            icon: Icons.arrow_back_rounded,
            loading: isUpdatingFulfillment,
            label: isUpdatingFulfillment
                ? 'جارٍ تحديث الحالة...'
                : order.fulfillmentStatus!.advanceActionLabel,
          ),
        ],
      );
    }

    return const _QuietState(
      icon: Icons.sync_rounded,
      title: 'تم اختيار عرضك',
      message: 'حدّث الصفحة للحصول على أحدث حالة تنفيذ.',
    );
  }
}

final class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final IconData icon;
  final String label;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SizedBox(
      height: _controlHeight,
      child: FilledButton(
        onPressed: onPressed,
        style:
            FilledButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ).copyWith(
              overlayColor: WidgetStatePropertyAll(
                colors.onPrimary.withValues(alpha: 0.12),
              ),
            ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: loading
              ? const SizedBox.square(
                  key: ValueKey('loading'),
                  dimension: 19,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Row(
                  key: ValueKey(label),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(label),
                    const SizedBox(width: 8),
                    Icon(icon, size: 19),
                  ],
                ),
        ),
      ),
    );
  }
}

final class _QuietState extends StatelessWidget {
  const _QuietState({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(_innerRadius),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _QuietIconButton extends StatelessWidget {
  const _QuietIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.child,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.7),
            shape: BoxShape.circle,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: colors.onSurface),
            child: child,
          ),
        ),
      ),
    );
  }
}

final class _InlineErrorBanner extends StatelessWidget {
  const _InlineErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _pageMaxWidth),
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsetsDirectional.fromSTEB(13, 9, 8, 9),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(_innerRadius),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline_rounded, size: 19, color: colors.error),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  message,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onErrorContainer,
                  ),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('تحديث')),
            ],
          ),
        ),
      ),
    );
  }
}

final class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: 26,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: 2.4,
              backgroundColor: colors.surfaceContainerHigh,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'جارٍ تحميل الطلبات',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

extension on ReceivedOrderFulfillmentStatus {
  String get displayLabel {
    return switch (this) {
      ReceivedOrderFulfillmentStatus.confirmed => 'تم التأكيد',
      ReceivedOrderFulfillmentStatus.preparing => 'قيد التجهيز',
      ReceivedOrderFulfillmentStatus.readyForDelivery => 'جاهز للتسليم',
      ReceivedOrderFulfillmentStatus.outForDelivery => 'خرج للتسليم',
      ReceivedOrderFulfillmentStatus.delivered => 'تم التسليم',
    };
  }

  String get advanceActionLabel {
    return switch (this) {
      ReceivedOrderFulfillmentStatus.confirmed => 'بدء التجهيز',
      ReceivedOrderFulfillmentStatus.preparing => 'تحديد كجاهز للتسليم',
      ReceivedOrderFulfillmentStatus.readyForDelivery => 'بدء التوصيل',
      ReceivedOrderFulfillmentStatus.outForDelivery => 'تأكيد التسليم',
      ReceivedOrderFulfillmentStatus.delivered => 'تم التسليم',
    };
  }

  int get progressStep {
    return switch (this) {
      ReceivedOrderFulfillmentStatus.confirmed => 0,
      ReceivedOrderFulfillmentStatus.preparing => 1,
      ReceivedOrderFulfillmentStatus.readyForDelivery => 2,
      ReceivedOrderFulfillmentStatus.outForDelivery => 3,
      ReceivedOrderFulfillmentStatus.delivered => 4,
    };
  }

  String get progressDescription {
    return switch (this) {
      ReceivedOrderFulfillmentStatus.confirmed =>
        'اختار العميل عرضك. يمكنك الآن بدء تجهيز الطلب.',
      ReceivedOrderFulfillmentStatus.preparing =>
        'يتم تجهيز العناصر التي اختارها العميل.',
      ReceivedOrderFulfillmentStatus.readyForDelivery =>
        'اكتمل التجهيز والطلب جاهز لبدء التوصيل.',
      ReceivedOrderFulfillmentStatus.outForDelivery =>
        'الطلب خرج للتوصيل وهو في طريقه للعميل.',
      ReceivedOrderFulfillmentStatus.delivered =>
        'اكتمل التنفيذ وتم تسجيل الطلب كمُسلّم.',
    };
  }
}

String _shortOrderId(String value) {
  if (value.length <= 8) {
    return value;
  }

  return value.substring(value.length - 8);
}

final class _ResponseDialog extends StatelessWidget {
  const _ResponseDialog({required this.order});

  final ReceivedOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
        child: _ResponseEditor(order: order, desktop: true),
      ),
    );
  }
}

final class _ResponseSheet extends StatelessWidget {
  const _ResponseSheet({required this.order});

  final ReceivedOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: _ResponseEditor(order: order, desktop: false),
      ),
    );
  }
}

final class _ResponseEditor extends StatefulWidget {
  const _ResponseEditor({required this.order, required this.desktop});

  final ReceivedOrderEntity order;
  final bool desktop;

  @override
  State<_ResponseEditor> createState() => _ResponseEditorState();
}

final class _ResponseEditorState extends State<_ResponseEditor> {
  late final Map<String, _ResponseDraft> _drafts;

  @override
  void initState() {
    super.initState();

    _drafts = {
      for (final item in widget.order.items)
        item.id: _ResponseDraft(
          availability: ReceivedOrderAvailability.full,
          availableQuantity: item.requestedQuantity.toString(),
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.desktop) ...[
          const SizedBox(height: 9),
          Center(
            child: Container(
              width: 38,
              height: 5,
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
        Padding(
          padding: EdgeInsets.fromLTRB(
            widget.desktop ? 24 : 20,
            widget.desktop ? 22 : 18,
            widget.desktop ? 24 : 20,
            14,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  Icons.reply_rounded,
                  size: 21,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رد المورد',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'حدد التوفر والكمية والسعر لكل عنصر.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _QuietIconButton(
                tooltip: 'إغلاق',
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(Icons.close_rounded, size: 20),
              ),
            ],
          ),
        ),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            itemCount: widget.order.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = widget.order.items[index];
              final draft = _drafts[item.id]!;

              return _ResponseItemEditor(
                key: ValueKey('${item.id}-${draft.availability.name}'),
                item: item,
                draft: draft,
                onAvailabilityChanged: (availability) {
                  setState(() {
                    draft.availability = availability;

                    switch (availability) {
                      case ReceivedOrderAvailability.full:
                        draft.availableQuantity = item.requestedQuantity
                            .toString();
                      case ReceivedOrderAvailability.partial:
                        draft.availableQuantity = item.requestedQuantity > 1
                            ? '1'
                            : '0';
                      case ReceivedOrderAvailability.unavailable:
                        draft.availableQuantity = '0';
                    }
                  });
                },
              );
            },
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              top: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            widget.desktop ? 24 : 18,
            12,
            widget.desktop ? 24 : 18,
            widget.desktop ? 18 : 14,
          ),
          child: Row(
            children: [
              if (widget.desktop) ...[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('إلغاء'),
                ),
                const Spacer(),
              ] else
                const Spacer(),
              SizedBox(
                height: 48,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('إرسال الرد'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submit() {
    final responses = <SubmitReceivedOrderItemResponse>[];

    for (final item in widget.order.items) {
      final draft = _drafts[item.id]!;
      final availableQuantity = int.tryParse(draft.availableQuantity.trim());

      if (availableQuantity == null) {
        _showError('أدخل كمية متاحة صحيحة لكل عنصر.');
        return;
      }

      num? offeredPrice;

      if (draft.offeredUnitPrice.trim().isNotEmpty) {
        offeredPrice = num.tryParse(draft.offeredUnitPrice.trim());

        if (offeredPrice == null) {
          _showError('أدخل سعرًا صحيحًا أو اترك السعر فارغًا.');
          return;
        }
      }

      responses.add(
        SubmitReceivedOrderItemResponse(
          orderRecipientItemId: item.id,
          availability: draft.availability,
          availableQuantity: availableQuantity,
          offeredUnitPrice: offeredPrice,
          responseNotes: draft.notes.trim().isEmpty ? null : draft.notes.trim(),
        ),
      );
    }

    Navigator.of(context).pop(responses);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// Each item editor lives inside its own soft tile for clearer separation.
final class _ResponseItemEditor extends StatelessWidget {
  const _ResponseItemEditor({
    required this.item,
    required this.draft,
    required this.onAvailabilityChanged,
    super.key,
  });

  final ReceivedOrderItemEntity item;
  final _ResponseDraft draft;
  final ValueChanged<ReceivedOrderAvailability> onAvailabilityChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final quantityEditable =
        draft.availability == ReceivedOrderAvailability.partial;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderProductThumbnail(imageUrl: item.imageUrl, size: 56),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: colors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'الكمية المطلوبة: ${item.requestedQuantity}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (item.unitPrice.trim().isNotEmpty) ...[
                      const SizedBox(height: 5),
                      Text(
                        'سعر الوحدة: ${item.unitPrice.trim()}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SegmentedButton<ReceivedOrderAvailability>(
            segments: const [
              ButtonSegment(
                value: ReceivedOrderAvailability.full,
                label: Text('متوفر بالكامل'),
                icon: Icon(Icons.check_circle_outline_rounded, size: 18),
              ),
              ButtonSegment(
                value: ReceivedOrderAvailability.partial,
                label: Text('جزئيًا'),
                icon: Icon(Icons.adjust_rounded, size: 18),
              ),
              ButtonSegment(
                value: ReceivedOrderAvailability.unavailable,
                label: Text('غير متوفر'),
                icon: Icon(Icons.cancel_outlined, size: 18),
              ),
            ],
            selected: {draft.availability},
            onSelectionChanged: (selection) {
              if (selection.isNotEmpty) {
                onAvailabilityChanged(selection.first);
              }
            },
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackFields = constraints.maxWidth < 282;

              if (stackFields) {
                return Column(
                  children: [
                    TextFormField(
                      initialValue: draft.availableQuantity,
                      enabled: quantityEditable,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(
                        context,
                        label: 'الكمية المتاحة',
                        prefixIcon: Icons.shopping_basket_outlined,
                      ),
                      onChanged: (value) {
                        draft.availableQuantity = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      initialValue: draft.offeredUnitPrice,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fieldDecoration(
                        context,
                        label: 'سعر العرض - اختياري',
                        prefixIcon: Icons.price_change_outlined,
                      ),
                      onChanged: (value) {
                        draft.offeredUnitPrice = value;
                      },
                    ),
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: draft.availableQuantity,
                      enabled: quantityEditable,
                      keyboardType: TextInputType.number,
                      decoration: _fieldDecoration(
                        context,
                        label: 'الكمية المتاحة',
                        prefixIcon: Icons.shopping_basket_outlined,
                      ),
                      onChanged: (value) {
                        draft.availableQuantity = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      initialValue: draft.offeredUnitPrice,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fieldDecoration(
                        context,
                        label: 'سعر العرض - اختياري',
                        prefixIcon: Icons.price_change_outlined,
                      ),
                      onChanged: (value) {
                        draft.offeredUnitPrice = value;
                      },
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 10),
          TextFormField(
            maxLength: 2000,
            maxLines: 2,
            decoration: _fieldDecoration(
              context,
              label: 'ملاحظات - اختيارية',
              prefixIcon: Icons.notes_rounded,
            ),
            onChanged: (value) {
              draft.notes = value;
            },
          ),
        ],
      ),
    );
  }
}

InputDecoration _fieldDecoration(
  BuildContext context, {
  required String label,
  IconData? prefixIcon,
}) {
  final colors = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: label,
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: colors.onSurfaceVariant),
    filled: true,
    fillColor: colors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: colors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(color: colors.primary, width: 1.4),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: BorderSide(
        color: colors.outlineVariant.withValues(alpha: 0.6),
      ),
    ),
  );
}

final class _ResponseDraft {
  _ResponseDraft({required this.availability, required this.availableQuantity});

  ReceivedOrderAvailability availability;
  String availableQuantity;
  String offeredUnitPrice = '';
  String notes = '';
}

final class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: _cardShadow(context),
                ),
                child: Icon(icon, size: 30, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (description != null) ...[
                const SizedBox(height: 7),
                Text(
                  description!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
              if (actionLabel != null && onPressed != null) ...[
                const SizedBox(height: 18),
                SizedBox(
                  height: 46,
                  child: FilledButton.tonal(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(actionLabel!),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/received_order_entity.dart';
import '../controllers/received_orders_controller.dart';
import '../providers/received_orders_provider.dart';

const double _pageMaxWidth = 760;
const double _pagePadding = 16;
const double _cardRadius = 22;
const double _innerRadius = 14;
const double _controlHeight = 50;

final class ReceivedOrdersPage extends ConsumerWidget {
  const ReceivedOrdersPage({required this.businessId, super.key});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(receivedOrdersControllerProvider(businessId));
    final state = controller.state;
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: Text(
          'الطلبات',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
      body: SafeArea(
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
      ),
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
        padding: const EdgeInsets.fromLTRB(_pagePadding, 12, _pagePadding, 32),
        itemCount: state.orders.length + 1,
        separatorBuilder: (_, index) => SizedBox(height: index == 0 ? 18 : 14),
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
        const SnackBar(
          content: Text('تم تحديث حالة الطلب.'),
          behavior: SnackBarBehavior.floating,
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
        const SnackBar(
          content: Text('تم إرسال الرد بنجاح.'),
          behavior: SnackBarBehavior.floating,
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
          Text(
            'الطلبات المستلمة',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'اعرف الحالة الحالية واتخذ الإجراء التالي بدون تشتيت.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
              height: 1.5,
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_cardRadius),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OrderHeader(order: order),
                  const SizedBox(height: 16),
                  _OrderSummary(order: order),
                  if (order.fulfillmentStatus != null) ...[
                    const SizedBox(height: 18),
                    _FulfillmentProgress(status: order.fulfillmentStatus!),
                  ],
                ],
              ),
            ),
            Divider(height: 1, color: colors.outlineVariant),
            _OrderItemsSection(order: order),
            if (order.notes?.trim().isNotEmpty ?? false) ...[
              Divider(height: 1, color: colors.outlineVariant),
              _OrderNotes(notes: order.notes!.trim()),
            ],
            Divider(height: 1, color: colors.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(16),
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
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.25,
                ),
              ),
              const SizedBox(height: 5),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  order.orderId,
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
    return Wrap(
      spacing: 18,
      runSpacing: 10,
      children: [
        _MetaValue(
          icon: Icons.shopping_bag_outlined,
          text:
              '${order.items.length} ${order.items.length == 1 ? 'عنصر' : 'عناصر'}',
        ),
        if (order.fulfillmentStatus != null)
          _MetaValue(
            icon: Icons.local_shipping_outlined,
            text: order.fulfillmentStatus!.displayLabel,
            emphasized: true,
          ),
        if (order.hasResponse && !order.hasSelection)
          _MetaValue(
            icon: Icons.person_search_outlined,
            text: 'بانتظار اختيار العميل',
          ),
      ],
    );
  }
}

final class _MetaValue extends StatelessWidget {
  const _MetaValue({
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

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 17,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: status
            ? colors.primary.withValues(alpha: 0.09)
            : colors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: status ? colors.primary : colors.onSurfaceVariant,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
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
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${currentStep + 1} من 5',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final active = index <= currentStep;
              return Expanded(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: index == 4 ? 0 : 5),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
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

final class _OrderItemsSection extends StatelessWidget {
  const _OrderItemsSection({required this.order});

  final ReceivedOrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'العناصر',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${order.items.length}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(_innerRadius),
            ),
            child: Column(
              children: [
                for (var index = 0; index < order.items.length; index++) ...[
                  _OrderItemRow(item: order.items[index]),
                  if (index < order.items.length - 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Divider(height: 1, color: colors.outlineVariant),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

final class _OrderItemRow extends StatelessWidget {
  const _OrderItemRow({required this.item});

  final ReceivedOrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item.productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '× ${item.requestedQuantity}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (item.selectedQuantity != null) ...[
                const SizedBox(height: 3),
                Text(
                  'مختار ${item.selectedQuantity}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ],
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
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
            child: Text(
              'الإجراء التالي',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
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

    return SizedBox(
      height: _controlHeight,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w700,
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
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: colors.onSurfaceVariant),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
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
            color: colors.surfaceContainerLow,
            shape: BoxShape.circle,
          ),
          child: child,
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
            color: colors.errorContainer.withValues(alpha: 0.65),
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
            widget.desktop ? 24 : 18,
            widget.desktop ? 24 : 20,
            16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'رد المورد',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 5),
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
        Divider(height: 1, color: colors.outlineVariant),
        Flexible(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
        Divider(height: 1, color: colors.outlineVariant),
        Padding(
          padding: EdgeInsets.fromLTRB(
            widget.desktop ? 24 : 18,
            14,
            widget.desktop ? 24 : 18,
            widget.desktop ? 20 : 16,
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
                    padding: const EdgeInsets.symmetric(horizontal: 22),
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
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }
}

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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.productName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '× ${item.requestedQuantity}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<ReceivedOrderAvailability>(
            initialValue: draft.availability,
            isExpanded: true,
            decoration: _fieldDecoration(context, label: 'حالة التوفر'),
            items: const [
              DropdownMenuItem(
                value: ReceivedOrderAvailability.full,
                child: Text('متوفر بالكامل'),
              ),
              DropdownMenuItem(
                value: ReceivedOrderAvailability.partial,
                child: Text('متوفر جزئيًا'),
              ),
              DropdownMenuItem(
                value: ReceivedOrderAvailability.unavailable,
                child: Text('غير متوفر'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                onAvailabilityChanged(value);
              }
            },
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackFields = constraints.maxWidth < 460;

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
                      ),
                      onChanged: (value) {
                        draft.availableQuantity = value;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fieldDecoration(
                        context,
                        label: 'السعر - اختياري',
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
                      ),
                      onChanged: (value) {
                        draft.availableQuantity = value;
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _fieldDecoration(
                        context,
                        label: 'السعر - اختياري',
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
            decoration: _fieldDecoration(context, label: 'ملاحظات - اختيارية'),
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
}) {
  final colors = Theme.of(context).colorScheme;

  return InputDecoration(
    labelText: label,
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
      borderSide: BorderSide(color: colors.outlineVariant),
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
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, size: 29, color: colors.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
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

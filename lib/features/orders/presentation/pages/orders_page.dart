import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../business/presentation/providers/business_provider.dart';
import '../../../received_orders/presentation/pages/received_orders_page.dart';

import '../../domain/entities/orders_entity.dart';
import '../extensions/order_status_presentation.dart';
import '../providers/orders_provider.dart';
import 'order_details_page.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordersProvider);
    final state = controller.state;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final Widget body;

    if (state.isLoading && state.orders.isEmpty) {
      body = const _OrdersLoading();
    } else if (state.errorMessage != null && state.orders.isEmpty) {
      body = _OrdersMessage(
        icon: Icons.cloud_off_rounded,
        title: 'تعذر تحميل الطلبيات',
        subtitle: state.errorMessage!,
        buttonText: 'إعادة المحاولة',
        onPressed: controller.loadOrders,
      );
    } else if (state.orders.isEmpty) {
      body = const _OrdersMessage(
        icon: Icons.receipt_long_rounded,
        title: 'لا توجد طلبيات بعد',
        subtitle: 'عندما ترسل طلبية جديدة ستظهر هنا ويمكنك متابعة حالتها.',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: controller.loadOrders,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth >= 700 ? 24.0 : 16.0;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                8,
                horizontalPadding,
                108,
              ),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _OrdersHeader(),
                        const SizedBox(height: 16),

                        ...List.generate(state.orders.length, (index) {
                          final OrderEntity order = state.orders[index];

                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index == state.orders.length - 1 ? 0 : 16,
                            ),
                            child: _OrderCard(
                              order: order,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        OrderDetailsPage(order: order),
                                  ),
                                );
                              },
                            ),
                          );
                        }),
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

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: colors.surfaceContainerLowest,
        appBar: AppBar(
          backgroundColor: colors.surfaceContainerLowest,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          toolbarHeight: 58,
          titleSpacing: 20,
          title: const Text(
            'الطلبات',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(62),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Container(
                key: const ValueKey<String>('orders-tabs-segment'),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: colors.primary,
                  unselectedLabelColor: colors.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(
                      key: ValueKey<String>('orders-sent-tab'),
                      height: 46,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.outbox_outlined, size: 18),
                          SizedBox(width: 7),
                          Text('طلباتي'),
                        ],
                      ),
                    ),
                    Tab(
                      key: ValueKey<String>('orders-received-tab'),
                      height: 46,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.move_to_inbox_outlined, size: 18),
                          SizedBox(width: 7),
                          Text('المستلمة'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'تحديث طلباتي',
              onPressed: state.isLoading ? null : controller.loadOrders,
              icon: const Icon(Icons.refresh_rounded),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: TabBarView(children: [body, const _ReceivedOrdersCenterTab()]),
      ),
    );
  }
}

class _ReceivedOrdersCenterTab extends ConsumerStatefulWidget {
  const _ReceivedOrdersCenterTab();

  @override
  ConsumerState<_ReceivedOrdersCenterTab> createState() =>
      _ReceivedOrdersCenterTabState();
}

class _ReceivedOrdersCenterTabState
    extends ConsumerState<_ReceivedOrdersCenterTab> {
  String? _selectedBusinessId;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final controller = ref.read(businessControllerProvider);

      if (controller.state.businesses.isEmpty) {
        controller.loadBusinesses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessController = ref.watch(businessControllerProvider);

    final businessState = businessController.state;
    final businesses = businessState.businesses;

    final colors = Theme.of(context).colorScheme;

    if (businesses.isEmpty) {
      return _OrdersMessage(
        icon: Icons.storefront_outlined,
        title: 'لا يوجد نشاط تجاري',
        subtitle: 'الطلبات المستلمة تظهر هنا عندما يكون لديك نشاط تجاري.',
        buttonText: 'تحديث الأنشطة',
        onPressed: businessController.loadBusinesses,
      );
    }

    final selectedBusinessId =
        _selectedBusinessId != null &&
            businesses.any((business) => business.id == _selectedBusinessId)
        ? _selectedBusinessId!
        : businesses.first.id;

    final selectedBusiness = businesses.firstWhere(
      (business) => business.id == selectedBusinessId,
    );

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          decoration: BoxDecoration(
            color: colors.surface,
            border: Border(
              bottom: BorderSide(
                color: colors.outlineVariant.withValues(alpha: 0.45),
              ),
            ),
          ),
          child: businesses.length > 1
              ? DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    key: const ValueKey<String>(
                      'received-orders-business-selector',
                    ),
                    value: selectedBusinessId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    items: businesses
                        .map(
                          (business) => DropdownMenuItem<String>(
                            value: business.id,
                            child: Row(
                              children: [
                                const Icon(Icons.storefront_outlined, size: 19),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    business.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null || value == selectedBusinessId) {
                        return;
                      }

                      setState(() {
                        _selectedBusinessId = value;
                      });
                    },
                  ),
                )
              : Row(
                  children: [
                    const Icon(Icons.storefront_outlined, size: 19),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedBusiness.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
        Expanded(
          child: ReceivedOrdersPage(
            key: ValueKey<String>(
              'embedded-received-orders-$selectedBusinessId',
            ),
            businessId: selectedBusinessId,
            embedded: true,
          ),
        ),
      ],
    );
  }
}

class _OrdersHeader extends StatelessWidget {
  const _OrdersHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 4, end: 4, top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'طلبياتك',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'تابع حالة طلبياتك وتفاصيلها من مكان واحد.',
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

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final OrderEntity order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final OrderAggregateStatus status = order.aggregateStatus;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: colors.shadow.withValues(alpha: 0.12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _OrderTopSection(order: order, status: status),

                const SizedBox(height: 12),

                _OrderItemsPreview(items: order.items),

                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.55),
                ),

                const SizedBox(height: 12),

                _OrderSummary(order: order),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 15,
                      color: colors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      _formatDate(order.createdAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'عرض التفاصيل',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 3),
                        Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderTopSection extends StatelessWidget {
  const _OrderTopSection({required this.order, required this.status});

  final OrderEntity order;
  final OrderAggregateStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
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
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.15,
                    ),
                  ),
                  const SizedBox(height: 5),
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

            _OrderStatusBadge(status: status),
          ],
        ),
      ],
    );
  }
}

class _OrderStatusBadge extends StatelessWidget {
  const _OrderStatusBadge({required this.status});

  final OrderAggregateStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: status.color.withValues(alpha: 0.09),
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

// Actual order items stay within the order card; horizontal scrolling keeps
// long multi-item orders compact on narrow Android screens.
class _OrderItemsPreview extends StatelessWidget {
  const _OrderItemsPreview({required this.items});

  final List<OrderItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'الأصناف',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              '${items.length} ${items.length == 1 ? 'صنف' : 'أصناف'}',
              style: theme.textTheme.labelMedium?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.swipe_rounded, size: 17, color: colors.onSurfaceVariant),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 110,
          child: ListView.separated(
            key: const ValueKey<String>('sent-order-items-horizontal'),
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, _) => const SizedBox(width: 9),
            itemBuilder: (context, index) => _SentItemMiniCard(
              item: items[index],
            ),
          ),
        ),
      ],
    );
  }
}

class _SentItemMiniCard extends StatelessWidget {
  const _SentItemMiniCard({required this.item});

  final OrderItemEntity item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final url = item.imageUrl.trim();

    return Container(
      width: 205,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: url.isEmpty
                    ? _fallback(colors)
                    : Image.network(
                        url,
                        width: 45,
                        height: 45,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _fallback(colors),
                      ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w700,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              Text(
                'العدد ${item.quantity}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  '${_formatPrice(item.totalPrice)} ر.ي',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _fallback(ColorScheme colors) => Container(
    width: 45,
    height: 45,
    color: colors.surfaceContainerHigh,
    alignment: Alignment.center,
    child: Icon(
      Icons.inventory_2_outlined,
      size: 21,
      color: colors.onSurfaceVariant,
    ),
  );
}

class _OrderSummary extends StatelessWidget {
  const _OrderSummary({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: _SummaryItem(
            icon: Icons.inventory_2_rounded,
            label: 'الكمية',
            value: '${order.totalQuantity}',
            suffix: 'منتج',
          ),
        ),

        Container(
          width: 1,
          height: 38,
          margin: const EdgeInsets.symmetric(horizontal: 18),
          color: colors.outlineVariant.withValues(alpha: 0.55),
        ),

        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'الإجمالي',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      _formatPrice(order.totalPrice),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Text(
                    'ر.ي',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.suffix,
  });

  final IconData icon;
  final String label;
  final String value;
  final String suffix;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Icon(icon, size: 17, color: colors.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                suffix,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OrdersLoading extends StatelessWidget {
  const _OrdersLoading();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: SizedBox.square(
        dimension: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: colors.primary,
        ),
      ),
    );
  }
}

class _OrdersMessage extends StatelessWidget {
  const _OrdersMessage({
    required this.icon,
    required this.title,
    this.subtitle,
    this.buttonText,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 96),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHigh,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 30, color: colors.onSurfaceVariant),
              ),

              const SizedBox(height: 20),

              Text(
                title,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),

              if (subtitle != null) ...[
                const SizedBox(height: 8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              ],

              if (buttonText != null && onPressed != null) ...[
                const SizedBox(height: 22),
                SizedBox(
                  height: 48,
                  child: FilledButton.tonal(
                    onPressed: onPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(buttonText!),
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

String _shortOrderId(String id) {
  final cleaned = id.trim();

  if (cleaned.length <= 8) {
    return cleaned;
  }

  return cleaned.substring(cleaned.length - 7);
}

String _formatDate(DateTime date) {
  final localDate = date.toLocal();

  return '${localDate.day}/${localDate.month}/${localDate.year}';
}

String _formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    return price.toStringAsFixed(0);
  }

  return price.toStringAsFixed(2);
}

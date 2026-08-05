import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/orders_entity.dart';
import '../providers/orders_provider.dart';

class OrdersPage extends ConsumerWidget {
  const OrdersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(ordersProvider);
    final state = controller.state;
    final Widget body;

    if (state.isLoading && state.orders.isEmpty) {
      body = const Center(
        child: CircularProgressIndicator(color: Color(0xFFE53935)),
      );
    } else if (state.errorMessage != null && state.orders.isEmpty) {
      body = _OrdersMessage(
        icon: Icons.cloud_off_rounded,
        title: state.errorMessage!,
        buttonText: 'إعادة المحاولة',
        onPressed: controller.loadOrders,
      );
    } else if (state.orders.isEmpty) {
      body = const _OrdersMessage(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد طلبيات حتى الآن',
        subtitle: 'ستظهر هنا الطلبيات التي ترسلها إلى الموردين',
      );
    } else {
      body = RefreshIndicator(
        color: const Color(0xFFE53935),
        onRefresh: controller.loadOrders,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          itemCount: state.orders.length,
          // إضافة مسافة بين الطلبات دون استخدام معاملات الفاصل.
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            return _OrderCard(order: state.orders[index]);
          },
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('الطلبيات'),
        centerTitle: true,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
      ),
      body: body,
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final OrderEntity order;

  @override
  Widget build(BuildContext context) {
    final status = _OrderStatusPresentation.from(order.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلبية #${order.id}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: status.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.label,
                  style: TextStyle(
                    color: status.color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 18,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text('${order.totalQuantity} منتج'),
              const Spacer(),
              Text(
                '${_formatPrice(order.totalPrice)} ر.ي',
                style: const TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                size: 16,
                color: Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                _formatDate(order.createdAt),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
            ],
          ),
        ],
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 90),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 62, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            if (buttonText != null && onPressed != null) ...[
              const SizedBox(height: 14),
              OutlinedButton(onPressed: onPressed, child: Text(buttonText!)),
            ],
          ],
        ),
      ),
    );
  }
}

class _OrderStatusPresentation {
  const _OrderStatusPresentation(this.label, this.color);

  factory _OrderStatusPresentation.from(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const _OrderStatusPresentation('قيد المراجعة', Colors.orange);
      case OrderStatus.confirmed:
        return const _OrderStatusPresentation('تم التأكيد', Colors.blue);
      case OrderStatus.preparing:
        return const _OrderStatusPresentation('قيد التجهيز', Colors.indigo);
      case OrderStatus.readyForDelivery:
        return const _OrderStatusPresentation('جاهزة للتسليم', Colors.teal);
      case OrderStatus.outForDelivery:
        return const _OrderStatusPresentation('في الطريق', Colors.purple);
      case OrderStatus.delivered:
        return const _OrderStatusPresentation('تم التسليم', Colors.green);
      case OrderStatus.cancelled:
        return const _OrderStatusPresentation('ملغاة', Colors.red);
    }
  }

  final String label;
  final Color color;
}

String _formatDate(DateTime date) {
  final localDate = date.toLocal();
  return '${localDate.day}/${localDate.month}/${localDate.year}';
}

String _formatPrice(double price) {
  if (price == price.truncateToDouble()) return price.toStringAsFixed(0);
  return price.toStringAsFixed(2);
}

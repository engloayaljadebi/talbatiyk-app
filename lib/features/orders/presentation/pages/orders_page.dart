import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/orders_entity.dart';
// خصائص العرض المشتركة لحالات الطلب.
import '../extensions/order_status_presentation.dart';
import '../providers/orders_provider.dart';
// صفحة تفاصيل الطلبية.
import 'order_details_page.dart';

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
            final OrderEntity order = state.orders[index];

            return _OrderCard(
              order: order,

              // فتح تفاصيل الطلبية المحددة.
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OrderDetailsPage(order: order),
                  ),
                );
              },
            );
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
  const _OrderCard({required this.order, required this.onTap});

  /// بيانات الطلب المعروض.
  final OrderEntity order;

  /// يعمل عند الضغط على بطاقة الطلب.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final OrderStatus status = order.status;
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
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

String _formatDate(DateTime date) {
  final localDate = date.toLocal();
  return '${localDate.day}/${localDate.month}/${localDate.year}';
}

String _formatPrice(double price) {
  if (price == price.truncateToDouble()) return price.toStringAsFixed(0);
  return price.toStringAsFixed(2);
}

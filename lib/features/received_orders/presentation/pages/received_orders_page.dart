import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/received_order_entity.dart';
import '../controllers/received_orders_controller.dart';
import '../providers/received_orders_provider.dart';

final class ReceivedOrdersPage extends ConsumerWidget {
  const ReceivedOrdersPage({required this.businessId, super.key});

  final String businessId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(receivedOrdersControllerProvider(businessId));
    final state = controller.state;

    final Widget body;

    if (state.isLoading && state.orders.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.errorMessage != null && state.orders.isEmpty) {
      body = _Message(
        icon: Icons.cloud_off_outlined,
        title: state.errorMessage!,
        actionLabel: 'إعادة المحاولة',
        onPressed: controller.loadReceivedOrders,
      );
    } else if (state.orders.isEmpty) {
      body = const _Message(
        icon: Icons.inventory_2_outlined,
        title: 'لا توجد طلبات مستلمة حاليًا',
      );
    } else {
      body = RefreshIndicator(
        onRefresh: controller.loadReceivedOrders,
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          itemCount: state.orders.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final order = state.orders[index];

            return _ReceivedOrderCard(
              order: order,
              isSubmitting: state.isSubmittingRecipient(order.id),
              onRespond: order.hasResponse
                  ? null
                  : () => _openResponseDialog(context, controller, order),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('الطلبات المستلمة'), centerTitle: true),
      body: Column(
        children: [
          if (state.errorMessage != null && state.orders.isNotEmpty)
            MaterialBanner(
              content: Text(state.errorMessage!),
              actions: [
                TextButton(
                  onPressed: controller.loadReceivedOrders,
                  child: const Text('تحديث'),
                ),
              ],
            ),
          Expanded(child: body),
        ],
      ),
    );
  }

  Future<void> _openResponseDialog(
    BuildContext context,
    ReceivedOrdersController controller,
    ReceivedOrderEntity order,
  ) async {
    final responses = await showDialog<List<SubmitReceivedOrderItemResponse>>(
      context: context,
      builder: (_) => _ResponseDialog(order: order),
    );

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('تم إرسال الرد بنجاح')));
    }
  }
}

final class _ReceivedOrderCard extends StatelessWidget {
  const _ReceivedOrderCard({
    required this.order,
    required this.isSubmitting,
    required this.onRespond,
  });

  final ReceivedOrderEntity order;
  final bool isSubmitting;
  final VoidCallback? onRespond;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'طلب #${order.orderId}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                _StatusChip(hasResponse: order.hasResponse),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '${order.items.length} عناصر',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (order.notes?.trim().isNotEmpty ?? false) ...[
              const SizedBox(height: 8),
              Text(order.notes!),
            ],
            const Divider(height: 24),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.productName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('المطلوب: ${item.requestedQuantity}'),
                  ],
                ),
              ),
            ),
            if (!order.hasResponse) ...[
              const SizedBox(height: 8),
              FilledButton(
                onPressed: isSubmitting ? null : onRespond,
                child: isSubmitting
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('الرد على الطلب'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

final class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.hasResponse});

  final bool hasResponse;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        hasResponse ? Icons.check_circle_outline : Icons.schedule,
        size: 18,
      ),
      label: Text(hasResponse ? 'تم الرد' : 'بانتظار الرد'),
    );
  }
}

final class _ResponseDialog extends StatefulWidget {
  const _ResponseDialog({required this.order});

  final ReceivedOrderEntity order;

  @override
  State<_ResponseDialog> createState() => _ResponseDialogState();
}

final class _ResponseDialogState extends State<_ResponseDialog> {
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
    return AlertDialog(
      title: const Text('رد المورد'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.order.items
                .map((item) {
                  final draft = _drafts[item.id]!;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _ResponseItemEditor(
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
                              draft.availableQuantity =
                                  item.requestedQuantity > 1 ? '1' : '0';

                            case ReceivedOrderAvailability.unavailable:
                              draft.availableQuantity = '0';
                          }
                        });
                      },
                    ),
                  );
                })
                .toList(growable: false),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _submit, child: const Text('إرسال الرد')),
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
    final quantityEditable =
        draft.availability == ReceivedOrderAvailability.partial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          item.productName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text('الكمية المطلوبة: ${item.requestedQuantity}'),
        const SizedBox(height: 12),
        DropdownButtonFormField<ReceivedOrderAvailability>(
          initialValue: draft.availability,
          decoration: const InputDecoration(
            labelText: 'حالة التوفر',
            border: OutlineInputBorder(),
          ),
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
        const SizedBox(height: 12),
        TextFormField(
          initialValue: draft.availableQuantity,
          enabled: quantityEditable,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'الكمية المتاحة',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            draft.availableQuantity = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'السعر المعروض - اختياري',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            draft.offeredUnitPrice = value;
          },
        ),
        const SizedBox(height: 12),
        TextFormField(
          maxLength: 2000,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'ملاحظات - اختيارية',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            draft.notes = value;
          },
        ),
      ],
    );
  }
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
    this.actionLabel,
    this.onPressed,
  });

  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center),
            if (actionLabel != null && onPressed != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onPressed, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

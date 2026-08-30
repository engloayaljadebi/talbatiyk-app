import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/order_response_comparison_entity.dart';
import '../providers/order_response_comparison_provider.dart';

class OrderResponseComparisonPage extends ConsumerWidget {
  const OrderResponseComparisonPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(
      orderResponseComparisonControllerProvider(orderId),
    );

    final state = controller.state;
    final comparison = state.comparison;

    final Widget body;

    if (state.isLoading && comparison == null) {
      body = const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    } else if (comparison == null) {
      body = _MessageView(
        icon: Icons.cloud_off_outlined,
        title: state.errorMessage ?? 'تعذر تحميل ردود الموردين.',
        buttonText: 'إعادة المحاولة',
        onPressed: controller.loadComparison,
      );
    } else {
      body = RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.loadComparison,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            _ComparisonHeader(comparison: comparison),
            const SizedBox(height: 16),
            if (state.errorMessage != null) ...[
              _ErrorBanner(message: state.errorMessage!),
              const SizedBox(height: 16),
            ],
            _SelectionForm(
              key: ValueKey<String>('${comparison.id}:${comparison.version}'),
              comparison: comparison,
              isSubmitting: state.isSubmitting,
              onSubmit: controller.submitSelections,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('ردود الموردين'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      body: body,
    );
  }
}

class _ComparisonHeader extends StatelessWidget {
  const _ComparisonHeader({required this.comparison});

  final OrderResponseComparisonEntity comparison;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'ملخص الردود',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'رقم الطلب: ${comparison.id}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'نسخة البيانات: ${comparison.version}',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if ((comparison.notes ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              comparison.notes!.trim(),
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SelectionForm extends StatefulWidget {
  const _SelectionForm({
    super.key,
    required this.comparison,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final OrderResponseComparisonEntity comparison;
  final bool isSubmitting;

  final Future<bool> Function(List<OrderResponseSelectionInput> selections)
  onSubmit;

  @override
  State<_SelectionForm> createState() => _SelectionFormState();
}

class _SelectionFormState extends State<_SelectionForm> {
  late final Map<String, int> _selectedQuantityByResponseId;

  String? _localError;

  @override
  void initState() {
    super.initState();

    _selectedQuantityByResponseId = <String, int>{
      for (final item in widget.comparison.items)
        if (item.response != null)
          item.response!.id: item.selection?.selectedQuantity ?? 0,
    };
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.comparison.items;

    final hasSelectableResponse = items.any((item) {
      final response = item.response;

      return response != null &&
          response.availability != OrderResponseAvailability.unavailable &&
          response.availableQuantity > 0;
    });

    return Column(
      children: [
        for (int index = 0; index < items.length; index++) ...[
          _ResponseItemCard(
            item: items[index],
            selectedQuantity: _quantityFor(items[index]),
            onDecrease: () => _changeQuantity(items[index], -1),
            onIncrease: () => _changeQuantity(items[index], 1),
          ),
          if (index < items.length - 1) const SizedBox(height: 14),
        ],
        if (_localError != null) ...[
          const SizedBox(height: 16),
          _ErrorBanner(message: _localError!),
        ],
        const SizedBox(height: 18),
        if (hasSelectableResponse)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('save-supplier-selections'),
              onPressed: widget.isSubmitting ? null : _submit,
              icon: widget.isSubmitting
                  ? const SizedBox(
                      width: 19,
                      height: 19,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                widget.isSubmitting ? 'جارٍ الحفظ...' : 'حفظ الاختيارات',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          )
        else
          const _MessageCard(
            message: 'لا توجد ردود متاحة يمكن اختيار كمية منها حاليًا.',
          ),
        const SizedBox(height: 10),
        const Text(
          'يجب الاحتفاظ بكمية موجبة من رد مورد واحد على الأقل عند الحفظ.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: AppColors.textHint,
            fontSize: 12,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  int _quantityFor(OrderResponseComparisonItemEntity item) {
    final response = item.response;

    if (response == null) {
      return 0;
    }

    return _selectedQuantityByResponseId[response.id] ?? 0;
  }

  void _changeQuantity(OrderResponseComparisonItemEntity item, int delta) {
    final response = item.response;

    if (response == null ||
        response.availability == OrderResponseAvailability.unavailable) {
      return;
    }

    final maximum = math.min(
      item.requestedQuantity,
      response.availableQuantity,
    );

    final current = _selectedQuantityByResponseId[response.id] ?? 0;

    final next = (current + delta).clamp(0, maximum);

    if (next == current) {
      return;
    }

    setState(() {
      _selectedQuantityByResponseId[response.id] = next;
      _localError = null;
    });
  }

  Future<void> _submit() async {
    final selections = <OrderResponseSelectionInput>[];

    for (final item in widget.comparison.items) {
      final response = item.response;

      if (response == null) {
        continue;
      }

      final quantity = _selectedQuantityByResponseId[response.id] ?? 0;

      if (quantity <= 0) {
        continue;
      }

      selections.add(
        OrderResponseSelectionInput(
          orderRecipientItemResponseId: response.id,
          selectedQuantity: quantity,
        ),
      );
    }

    if (selections.isEmpty) {
      setState(() {
        _localError = 'اختر كمية من رد مورد واحد على الأقل قبل الحفظ.';
      });
      return;
    }

    setState(() {
      _localError = null;
    });

    await widget.onSubmit(selections);
  }
}

class _ResponseItemCard extends StatelessWidget {
  const _ResponseItemCard({
    required this.item,
    required this.selectedQuantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final OrderResponseComparisonItemEntity item;
  final int selectedQuantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final response = item.response;

    return _SectionCard(
      title: item.productName,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoRow(label: 'المورد', value: item.supplier.supplierName),
          const SizedBox(height: 10),
          _InfoRow(
            label: 'الكمية المطلوبة',
            value: '${item.requestedQuantity}',
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'سعر الطلب', value: '${item.orderUnitPrice} ر.س'),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 14),
          if (response == null)
            const _MessageCard(
              message: 'لم يصل رد نهائي من المورد لهذا العنصر بعد.',
            )
          else ...[
            _InfoRow(
              label: 'حالة التوفر',
              value: _availabilityLabel(response.availability),
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'الكمية المتاحة',
              value: '${response.availableQuantity}',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              label: 'السعر المعروض',
              value: response.offeredUnitPrice == null
                  ? 'غير محدد'
                  : '${response.offeredUnitPrice} ر.س',
            ),
            if ((response.responseNotes ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                response.responseNotes!.trim(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
            const SizedBox(height: 16),
            _QuantitySelector(
              responseId: response.id,
              selectedQuantity: selectedQuantity,
              maximum: math.min(
                item.requestedQuantity,
                response.availableQuantity,
              ),
              enabled:
                  response.availability !=
                      OrderResponseAvailability.unavailable &&
                  response.availableQuantity > 0,
              onDecrease: onDecrease,
              onIncrease: onIncrease,
            ),
          ],
        ],
      ),
    );
  }
}

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.responseId,
    required this.selectedQuantity,
    required this.maximum,
    required this.enabled,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String responseId;
  final int selectedQuantity;
  final int maximum;
  final bool enabled;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const Text(
        'هذا الرد غير متاح للاختيار.',
        style: TextStyle(
          color: AppColors.textHint,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return Row(
      children: [
        const Expanded(
          child: Text(
            'الكمية المختارة',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        IconButton(
          key: Key('selection-decrement-$responseId'),
          onPressed: selectedQuantity > 0 ? onDecrease : null,
          icon: const Icon(Icons.remove_circle_outline),
        ),
        SizedBox(
          width: 40,
          child: Text(
            '$selectedQuantity',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        IconButton(
          key: Key('selection-increment-$responseId'),
          onPressed: selectedQuantity < maximum ? onIncrease : null,
          icon: const Icon(Icons.add_circle_outline),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const Spacer(),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.25)),
      ),
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.error,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        message,
        style: const TextStyle(color: AppColors.textSecondary, height: 1.5),
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.buttonText,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 58, color: AppColors.textHint),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onPressed, child: Text(buttonText)),
          ],
        ),
      ),
    );
  }
}

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

String _availabilityLabel(OrderResponseAvailability availability) {
  return switch (availability) {
    OrderResponseAvailability.full => 'متوفر بالكامل',
    OrderResponseAvailability.partial => 'متوفر جزئيًا',
    OrderResponseAvailability.unavailable => 'غير متوفر',
  };
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../sharing/cart_share_data.dart';
import '../../sharing/cart_share_pdf.dart';
import '../../sharing/cart_share_text.dart';
import '../controllers/cart_controller.dart';
import '../providers/cart_provider.dart';

class CartShareButton extends ConsumerWidget {
  const CartShareButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return IconButton(
      tooltip: 'مشاركة الطلبية',
      icon: const Icon(Icons.share_outlined),
      onPressed: cart.isEmpty || cart.isSwitching
          ? null
          : () => _openPreview(context, ref, cart),
    );
  }

  Future<void> _openPreview(
    BuildContext context,
    WidgetRef ref,
    CartController cart,
  ) async {
    final cartId = cart.activeCartId;
    await cart.ready;
    if (!context.mounted ||
        !identical(ref.read(cartProvider), cart) ||
        cart.activeCartId != cartId ||
        cart.isSwitching ||
        cart.isEmpty) {
      return;
    }

    final items = List<CartItemEntity>.unmodifiable(cart.items);
    await showDialog<void>(
      context: context,
      builder: (_) =>
          _CartShareDialog(cart: cart, cartId: cartId, items: items),
    );
  }
}

class _CartShareDialog extends ConsumerStatefulWidget {
  const _CartShareDialog({
    required this.cart,
    required this.cartId,
    required this.items,
  });

  final CartController cart;
  final String? cartId;
  final List<CartItemEntity> items;

  @override
  ConsumerState<_CartShareDialog> createState() => _CartShareDialogState();
}

class _CartShareDialogState extends ConsumerState<_CartShareDialog> {
  bool _shareAsPdf = false;
  bool _showPrices = false;
  bool _sharing = false;
  String? _error;
  final Set<int> _excludedNotes = {};

  bool _isCurrentCart(CartController current) =>
      identical(current, widget.cart) &&
      current.activeCartId == widget.cartId &&
      !current.isSwitching;

  @override
  Widget build(BuildContext context) {
    final current = ref.watch(cartProvider);
    if (!_isCurrentCart(current)) {
      return AlertDialog(
        title: const Text('تغيّرت السلة'),
        content: const Text('افتح المشاركة مجددًا من السلة الحالية.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      );
    }

    final data = CartShareData.fromItems(
      widget.items,
      options: CartShareOptions(
        showPrices: _showPrices,
        excludedNoteIndexes: _excludedNotes,
      ),
    );
    final text = buildCartShareText(data);

    return AlertDialog(
      scrollable: true,
      title: const Text('مشاركة الطلبية'),
      content: SizedBox(
        width: 440,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('مشاركة كملف PDF'),
              value: _shareAsPdf,
              onChanged: _sharing
                  ? null
                  : (value) => setState(() => _shareAsPdf = value),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('إظهار الأسعار'),
              value: _showPrices,
              onChanged: _sharing
                  ? null
                  : (value) => setState(() => _showPrices = value),
            ),
            for (final (index, item) in widget.items.indexed)
              if (item.note?.trim().isNotEmpty ?? false)
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text('تضمين ملاحظة ${item.product.name}'),
                  value: !_excludedNotes.contains(index),
                  onChanged: _sharing
                      ? null
                      : (include) => setState(() {
                          if (include == true) {
                            _excludedNotes.remove(index);
                          } else {
                            _excludedNotes.add(index);
                          }
                        }),
                ),
            const Divider(),
            SelectableText(text, textDirection: TextDirection.rtl),
            if (_error != null) ...[const SizedBox(height: 12), Text(_error!)],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _sharing ? null : () => Navigator.of(context).pop(),
          child: const Text('إغلاق'),
        ),
        Builder(
          builder: (buttonContext) => FilledButton(
            onPressed: _sharing ? null : () => _share(buttonContext, data),
            child: Text(_sharing ? 'جارٍ فتح المشاركة…' : 'مشاركة'),
          ),
        ),
      ],
    );
  }

  Future<void> _share(BuildContext buttonContext, CartShareData data) async {
    if (_sharing || !_isCurrentCart(ref.read(cartProvider))) return;

    final renderObject = buttonContext.findRenderObject();
    final origin = renderObject is RenderBox && renderObject.hasSize
        ? renderObject.localToGlobal(Offset.zero) & renderObject.size
        : null;

    setState(() {
      _sharing = true;
      _error = null;
    });

    try {
      if (_shareAsPdf) {
        final bytes = await buildCartSharePdf(data);
        if (!mounted || !_isCurrentCart(ref.read(cartProvider))) return;

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile.fromData(bytes, mimeType: 'application/pdf')],
            fileNameOverrides: const ['order-list.pdf'],
            sharePositionOrigin: origin,
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: buildCartShareText(data),
            sharePositionOrigin: origin,
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'تعذر فتح المشاركة. حاول مرة أخرى.');
      }
    } finally {
      if (mounted) {
        setState(() => _sharing = false);
      }
    }
  }
}

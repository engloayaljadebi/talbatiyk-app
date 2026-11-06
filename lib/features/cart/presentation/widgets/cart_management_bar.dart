import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/cart_controller.dart';
import '../providers/cart_provider.dart';

class CartManagementBar extends ConsumerWidget {
  const CartManagementBar({super.key});

  static const Color _primary = Color(0xFFE53935);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(cartProvider);
    final cartsAsync = ref.watch(cartListProvider);

    return FutureBuilder<void>(
      future: controller.ready,
      builder: (context, readySnapshot) {
        if (readySnapshot.connectionState != ConnectionState.done) {
          return const SizedBox(height: 8);
        }

        if (readySnapshot.hasError) {
          return const SizedBox.shrink();
        }

        final activeCartId = controller.activeCartId;

        final activeCartName = cartsAsync.when(
          data: (carts) {
            for (final cart in carts) {
              if (cart.id == activeCartId) {
                return cart.name;
              }
            }
            return activeCartId == null ? 'لا توجد سلة نشطة' : 'السلة الحالية';
          },
          loading: () => 'جارٍ تحميل السلات...',
          error: (_, _) => 'تعذر تحميل السلات',
        );

        final canChooseCart = cartsAsync.maybeWhen(
          data: (carts) => carts.isNotEmpty,
          orElse: () => false,
        );

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.isSwitching || !canChooseCart
                      ? null
                      : () => _showCartSelector(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF252525),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    side: const BorderSide(color: Color(0xFFE8E8EA)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.shopping_bag_outlined,
                        color: _primary,
                        size: 21,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'السلة النشطة',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF858585),
                              ),
                            ),
                            Text(
                              activeCartName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down_rounded),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'إنشاء سلة جديدة',
                onPressed: controller.isSwitching
                    ? null
                    : () => _showCreateCartDialog(context, ref),
                style: IconButton.styleFrom(
                  foregroundColor: _primary,
                  backgroundColor: const Color(0xFFFFEEEE),
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  static Future<void> _showCartSelector(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      final carts = await ref.read(cartListProvider.future);
      if (!context.mounted) return;

      if (carts.isEmpty) {
        _showMessage(context, 'لا توجد سلات محفوظة.');
        return;
      }

      final controller = ref.read(cartProvider);

      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (sheetContext) {
          final activeId = controller.activeCartId;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'اختيار السلة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                        },
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.55,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: carts.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = carts[index];
                        final isActive = item.id == activeId;

                        return ListTile(
                          leading: Icon(
                            isActive
                                ? Icons.radio_button_checked_rounded
                                : Icons.radio_button_off_rounded,
                            color: isActive ? _primary : Colors.grey,
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: isActive
                              ? const Text('السلة النشطة')
                              : null,
                          onTap: () async {
                            Navigator.pop(sheetContext);

                            if (isActive) return;

                            final result = await controller.switchToCart(
                              item.id,
                            );

                            if (!context.mounted) return;

                            _showSwitchResult(context, item.name, result);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'تعذر تحميل السلات.');
      }
    }
  }

  static Future<void> _showCreateCartDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => const _CreateCartDialog(),
    );

    if (name == null || !context.mounted) return;

    try {
      final created = await ref.read(cartProvider).createCartAndActivate(name);

      ref.invalidate(cartListProvider);

      if (!context.mounted) return;

      _showMessage(context, 'تم إنشاء وتفعيل السلة: ${created.name}');
    } catch (_) {
      if (context.mounted) {
        _showMessage(context, 'تعذر إنشاء السلة الجديدة.');
      }
    }
  }

  static void _showSwitchResult(
    BuildContext context,
    String cartName,
    CartSwitchResult result,
  ) {
    switch (result) {
      case CartSwitchResult.switched:
        _showMessage(context, 'تم التبديل إلى: $cartName');
        break;
      case CartSwitchResult.alreadyActive:
        _showMessage(context, 'هذه السلة نشطة بالفعل.');
        break;
      case CartSwitchResult.unavailable:
        _showMessage(context, 'السلة غير متاحة لهذا الحساب.');
        break;
      case CartSwitchResult.busy:
        _showMessage(context, 'هناك عملية تبديل قيد التنفيذ.');
        break;
      case CartSwitchResult.failed:
        _showMessage(context, 'تعذر تبديل السلة.');
        break;
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _CreateCartDialog extends StatefulWidget {
  const _CreateCartDialog();
  @override
  State<_CreateCartDialog> createState() => _CreateCartDialogState();
}

class _CreateCartDialogState extends State<_CreateCartDialog> {
  late final TextEditingController _nameController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.of(context).pop(_nameController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنشاء سلة جديدة'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _nameController,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'اسم السلة',
            hintText: 'مثال: مشتريات المنزل',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'يرجى إدخال اسم السلة';
            }
            return null;
          },
          onFieldSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton(onPressed: _submit, child: const Text('إنشاء وتفعيل')),
      ],
    );
  }
}

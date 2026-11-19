import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:talbatiyk/features/cart/domain/entities/cart_item_entity.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/orders/domain/entities/orders_entity.dart';
import 'package:talbatiyk/features/orders/presentation/providers/orders_provider.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_image.dart';
import 'package:talbatiyk/features/supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import 'package:talbatiyk/features/supplier_discovery/presentation/providers/supplier_discovery_provider.dart';
import 'package:talbatiyk/features/cart/presentation/widgets/cart_management_bar.dart';

/// صفحة سلة المشتريات.
///
/// التصميم:
/// - تنظيم المنتجات حسب المورد.
/// - Checkout bar ثابتة أسفل الشاشة.
/// - Micro-interactions وحركات دخول وانتقال.
/// - حالات Empty / Loading واضحة.
/// - دعم عدة موردين داخل الطلبية.
/// - المحافظة على Cart persistence وOrders logic كما هما.
class CartPage extends ConsumerWidget {
  const CartPage({super.key});

  static const Color _primary = Color(0xFFE53935);
  static const Color _background = Color(0xFFF6F7F9);
  static const Color _textPrimary = Color(0xFF17181A);
  static const Color _textSecondary = Color(0xFF73777F);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final CartController cart = ref.watch(cartProvider);
    final ordersController = ref.watch(ordersProvider);
    final supplierDiscoveryController = ref.watch(
      supplierDiscoveryControllerProvider,
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: _buildAppBar(context, ref, cart),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const CartManagementBar(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: cart.isSwitching
                      ? null
                      : () => _showManualItemDialog(context, ref),
                  icon: const Icon(Icons.edit_note_rounded),
                  label: const Text('إضافة صنف يدوي'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _primary,
                    side: BorderSide(color: _primary.withValues(alpha: 0.28)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                transitionBuilder: (child, animation) {
                  final slideAnimation = Tween<Offset>(
                    begin: const Offset(0, 0.025),
                    end: Offset.zero,
                  ).animate(animation);

                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: slideAnimation,
                      child: child,
                    ),
                  );
                },
                child: cart.isEmpty
                    ? const _EmptyCart(key: ValueKey('empty-cart'))
                    : _CartContent(
                        key: const ValueKey('cart-content'),
                        items: cart.items,
                      ),
              ),
            ),
            if (cart.isNotEmpty)
              _CheckoutBar(
                // مفتاح ثابت يستخدمه Regression Test لإثبات ظهور Checkout bar.
                key: const ValueKey('checkout-bar'),
                totalQuantity: cart.totalQuantity,
                totalPrice: cart.totalPrice,
                isSubmitting:
                    ordersController.state.isSubmitting ||
                    supplierDiscoveryController.state.isLoading,
                onSubmit: () {
                  _submitOrder(context, ref, cart);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _showManualItemDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final draft = await showDialog<_ManualCartItemDraft>(
      context: context,
      builder: (_) => const _ManualCartItemDialog(),
    );

    if (draft == null || !context.mounted) {
      return;
    }

    final itemId = ref
        .read(cartProvider)
        .addManualItem(
          name: draft.name,
          unitPrice: draft.unitPrice,
          quantity: draft.quantity,
          unit: draft.unit,
          note: draft.note,
        );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            itemId == null
                ? 'تعذر إضافة الصنف أثناء تبديل السلة.'
                : 'تمت إضافة ${draft.name} إلى السلة.',
          ),
        ),
      );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    WidgetRef ref,
    CartController cart,
  ) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      centerTitle: false,
      titleSpacing: 20,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'السلة',
            style: TextStyle(
              color: _textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: cart.isEmpty
                ? const SizedBox.shrink()
                : Text(
                    '${cart.totalQuantity} ${_itemsLabel(cart.totalQuantity)}',
                    key: ValueKey(cart.totalQuantity),
                    style: const TextStyle(
                      color: _textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
      actions: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: FadeTransition(opacity: animation, child: child),
            );
          },
          child: cart.isEmpty
              ? const SizedBox(key: ValueKey('clear-hidden'), width: 16)
              : Padding(
                  key: const ValueKey('clear-visible'),
                  padding: const EdgeInsetsDirectional.only(end: 10),
                  child: IconButton(
                    tooltip: 'تفريغ السلة',
                    onPressed: () {
                      _confirmClearCart(context, ref);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFFFFF1F1),
                      foregroundColor: _primary,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 21),
                  ),
                ),
        ),
      ],
    );
  }

  Future<void> _confirmClearCart(BuildContext context, WidgetRef ref) async {
    final bool shouldClear =
        await showDialog<bool>(
          context: context,
          barrierColor: Colors.black.withValues(alpha: 0.35),
          builder: (dialogContext) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              contentPadding: const EdgeInsets.fromLTRB(24, 18, 24, 8),
              actionsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              title: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFEBEE),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_outline_rounded,
                      color: _primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'تفريغ السلة',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              content: const Text(
                'سيتم حذف جميع المنتجات الموجودة في السلة. '
                'لا يمكن التراجع عن هذه العملية.',
                style: TextStyle(
                  color: _textSecondary,
                  height: 1.6,
                  fontSize: 14,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('حذف الكل'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (shouldClear) {
      ref.read(cartProvider).clear();
    }
  }

  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    CartController cart,
  ) async {
    await cart.ready;
    if (!context.mounted || cart.isEmpty || cart.isSwitching) {
      return;
    }
    final submittingCartId = cart.activeCartId;

    final supplierDiscoveryController = ref.read(
      supplierDiscoveryControllerProvider,
    );

    final loaded = await supplierDiscoveryController.loadSuppliers();

    if (!context.mounted) {
      return;
    }

    if (!loaded) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              supplierDiscoveryController.state.errorMessage ??
                  'تعذر تحميل الموردين المتاحين.',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );

      return;
    }

    final suppliers = supplierDiscoveryController.state.suppliers;
    final usingCachedSuppliers = supplierDiscoveryController.state.isFromCache;

    if (suppliers.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: const Text('لا يوجد موردون مؤهلون لاستقبال الطلب حاليًا.'),
            backgroundColor: Colors.red.shade700,
          ),
        );

      return;
    }

    final selectedSuppliers = await _selectSuppliers(context, suppliers);

    if (!context.mounted ||
        selectedSuppliers == null ||
        selectedSuppliers.isEmpty ||
        cart.isSwitching ||
        cart.activeCartId != submittingCartId) {
      return;
    }

    // Capture the latest cart state after supplier selection.
    final currentItems = cart.items;

    if (currentItems.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('السلة فارغة، أضف منتجات قبل إرسال الطلبية.'),
          ),
        );

      return;
    }

    final submittedItems = List<CartItemEntity>.unmodifiable(currentItems);
    final request = CreateOrderRequest(
      supplierIds: selectedSuppliers.toList()..sort(),
      items: submittedItems
          .map((item) {
            if (item.isManual) {
              return OrderItemEntity(
                itemType: 'manual',
                productId: null,
                productName: item.product.name,
                unitPrice: item.unitPrice,
                quantity: item.quantity,
                supplierId: null,
                supplierName: '',
                unit: item.unit,
                note: item.note,
              );
            }

            return OrderItemEntity(
              productId: item.product.id,
              productName: item.product.name,
              unitPrice: item.product.price,
              quantity: item.quantity,
              supplierId: item.product.supplierId,
              supplierName: item.product.supplierName,
              imageUrl: item.product.imageUrl,
            );
          })
          .toList(growable: false),
    );

    final ordersController = ref.read(ordersProvider);

    final createdOrder = await ordersController.createOrder(request);

    if (!context.mounted) {
      return;
    }

    if (createdOrder == null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              ordersController.state.errorMessage ??
                  'تعذر إرسال الطلبية، حاول مرة أخرى',
            ),
            backgroundColor: Colors.red.shade700,
          ),
        );

      return;
    }

    cart.removeSubmittedItems(submittingCartId, submittedItems);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            usingCachedSuppliers
                ? 'تم حفظ الطلبية #${createdOrder.id} محليًا، وستُرسل عند عودة الاتصال.'
                : 'تم حفظ الطلبية #${createdOrder.id}، ويمكنك متابعتها من الطلبات.',
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );
  }

  Future<Set<String>?> _selectSuppliers(
    BuildContext context,
    List<SupplierCandidateEntity> suppliers,
  ) async {
    final selected = <String>{};

    return showDialog<Set<String>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('اختر الموردين'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if (suppliers.first.isFromCache)
                      const Text(
                        'هذه قائمة محفوظة. ستُرسل الطلبية عند عودة الاتصال، وقد تتغير أهلية الموردين.',
                      ),
                    ...suppliers.map((supplier) {
                      return CheckboxListTile(
                        value: selected.contains(supplier.id),
                        contentPadding: EdgeInsets.zero,
                        title: Text(supplier.name),
                        onChanged: (value) {
                          setState(() {
                            if (value == true) {
                              selected.add(supplier.id);
                            } else {
                              selected.remove(supplier.id);
                            }
                          });
                        },
                      );
                    }),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: selected.isEmpty
                      ? null
                      : () {
                          Navigator.pop(
                            dialogContext,
                            Set<String>.unmodifiable(selected),
                          );
                        },
                  child: Text(
                    selected.length > 1
                        ? 'إرسال للموردين المحددين'
                        : 'إرسال للمورد المحدد',
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _ManualCartItemDraft {
  const _ManualCartItemDraft({
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.unit,
    this.note,
  });

  final String name;
  final int quantity;
  final double unitPrice;
  final String? unit;
  final String? note;
}

class _ManualCartItemDialog extends StatefulWidget {
  const _ManualCartItemDialog();

  @override
  State<_ManualCartItemDialog> createState() => _ManualCartItemDialogState();
}

class _ManualCartItemDialogState extends State<_ManualCartItemDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController();
  final _noteController = TextEditingController();

  int _quantity = 1;
  bool _showDetails = false;

  double? get _parsedUnitPrice {
    return double.tryParse(_priceController.text.trim());
  }

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _nameController.dispose();
    _priceController.dispose();
    _unitController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم الصنف مطلوب.';
    }

    return null;
  }

  String? _validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'سعر الوحدة مطلوب.';
    }

    final price = _parsedUnitPrice;

    if (price == null || !price.isFinite || price < 0) {
      return 'أدخل سعرًا صحيحًا.';
    }

    return null;
  }

  InputDecoration _decoration(String label) {
    return InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final price = _parsedUnitPrice!;

    Navigator.of(context).pop(
      _ManualCartItemDraft(
        name: _nameController.text.trim(),
        quantity: _quantity,
        unitPrice: price,
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        note: _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final unitPrice = _parsedUnitPrice;
    final totalPrice = unitPrice == null ? null : unitPrice * _quantity;

    return AlertDialog(
      title: const Text(
        'إضافة صنف يدوي',
        style: TextStyle(fontWeight: FontWeight.w800),
      ),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _decoration('اسم الصنف *'),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Text(
                      'الكمية *',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'تقليل الكمية',
                      onPressed: _quantity <= 1
                          ? null
                          : () {
                              setState(() => _quantity--);
                            },
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    SizedBox(
                      width: 30,
                      child: Center(
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'زيادة الكمية',
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                TextFormField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: _decoration('سعر الوحدة *'),
                  validator: _validatePrice,
                ),
                const SizedBox(height: 14),

                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'إجمالي الصنف',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        totalPrice == null
                            ? '—'
                            : '${_formatPrice(totalPrice)} ر.ي',
                        style: const TextStyle(
                          color: CartPage._primary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _showDetails = !_showDetails;
                      });
                    },
                    icon: Icon(
                      _showDetails
                          ? Icons.expand_less_rounded
                          : Icons.expand_more_rounded,
                    ),
                    label: Text(
                      _showDetails ? 'إخفاء التفاصيل' : 'تفاصيل إضافية',
                    ),
                  ),
                ),

                if (_showDetails) ...[
                  TextFormField(
                    controller: _unitController,
                    textInputAction: TextInputAction.next,
                    decoration: _decoration('الوحدة (اختياري)'),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 2,
                    decoration: _decoration('ملاحظة (اختيارية)'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        FilledButton.icon(
          onPressed: _submit,
          icon: const Icon(Icons.add_rounded),
          label: const Text('إضافة إلى السلة'),
        ),
      ],
    );
  }
}

/// محتوى السلة.
///
/// يتم تنظيم المنتجات حسب المورد بدل عرض جميع المنتجات
/// كقائمة مسطحة.
class _CartContent extends StatelessWidget {
  const _CartContent({super.key, required this.items});

  final List<CartItemEntity> items;

  @override
  Widget build(BuildContext context) {
    final groups = _groupBySupplier(items);

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return _AppearAnimation(
          index: index,
          child: _SupplierSection(group: groups[index]),
        );
      },
    );
  }
}

/// قسم مورد كامل.
class _SupplierSection extends StatelessWidget {
  const _SupplierSection({required this.group});

  final _SupplierGroup group;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SupplierHeader(group: group),
          const SizedBox(height: 10),
          ...List.generate(group.items.length, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == group.items.length - 1 ? 0 : 10,
              ),
              child: _AppearAnimation(
                index: index,
                baseDelay: 50,
                child: _CartItemCard(item: group.items[index]),
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// عنوان المورد.
class _SupplierHeader extends StatelessWidget {
  const _SupplierHeader({required this.group});

  final _SupplierGroup group;

  @override
  Widget build(BuildContext context) {
    final quantity = group.items.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEE),
            shape: BoxShape.circle,
          ),
          child: Icon(
            group.key == 'manual-items'
                ? Icons.edit_note_rounded
                : Icons.storefront_outlined,
            color: CartPage._primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CartPage._textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$quantity ${_itemsLabel(quantity)}',
                style: const TextStyle(
                  color: CartPage._textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// بطاقة المنتج داخل السلة.
class _CartItemCard extends ConsumerWidget {
  const _CartItemCard({required this.item});

  final CartItemEntity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = item.product;

    Widget buildImage(double size) {
      if (item.isManual) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(17),
          ),
          child: const Icon(
            Icons.edit_note_rounded,
            color: CartPage._primary,
            size: 34,
          ),
        );
      }

      return Hero(
        tag: 'cart-product-${product.id}',
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Container(
            width: size,
            height: size,
            color: const Color(0xFFF6F6F7),
            child: ProductImage(imageUrl: product.displayImagePath),
          ),
        ),
      );
    }

    Widget buildDetails(double minHeight) {
      final lineTotal = item.totalPrice;

      return ConstrainedBox(
        constraints: BoxConstraints(minHeight: minHeight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: CartPage._textPrimary,
                fontSize: 14.5,
                height: 1.25,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (item.isManual && item.unit != null) ...[
              const SizedBox(height: 3),
              Text(
                'الوحدة: ${item.unit}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CartPage._textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
            if (item.isManual && item.note != null) ...[
              const SizedBox(height: 3),
              Text(
                item.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CartPage._textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
            if (!item.isManual && product.brand.trim().isNotEmpty) ...[
              const SizedBox(height: 3),
              Text(
                product.brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CartPage._textSecondary,
                  fontSize: 11.5,
                ),
              ),
            ],
            const SizedBox(height: 6),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Text(
                '${_formatPrice(lineTotal)} ر.ي',
                key: ValueKey(lineTotal),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: CartPage._primary,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildRemoveButton() {
      return _RemoveButton(
        onPressed: () {
          final controller = ref.read(cartProvider);

          if (item.isManual) {
            controller.removeManualItem(item.id);
          } else {
            controller.removeProduct(product.id);
          }
        },
      );
    }

    Widget buildQuantityControl({required bool compact}) {
      return _QuantityControl(
        quantity: item.quantity,
        compact: compact,
        onDecrease: () {
          final controller = ref.read(cartProvider);

          if (item.isManual) {
            controller.decreaseManualItem(item.id);
          } else {
            controller.decreaseProduct(product.id);
          }
        },
        onIncrease: () {
          final controller = ref.read(cartProvider);

          if (item.isManual) {
            controller.increaseManualItem(item.id);
          } else {
            controller.addProduct(product);
          }
        },
      );
    }

    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.black.withValues(alpha: 0.045)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // At phone widths, put controls on a second row so the product
          // details keep enough horizontal space and the card cannot overflow.
          final compact = constraints.maxWidth < 340;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    buildImage(72),
                    const SizedBox(width: 10),
                    Expanded(child: buildDetails(72)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    buildRemoveButton(),
                    const SizedBox(width: 8),
                    buildQuantityControl(compact: true),
                  ],
                ),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              buildImage(90),
              const SizedBox(width: 13),
              Expanded(child: buildDetails(90)),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildRemoveButton(),
                  const SizedBox(height: 8),
                  buildQuantityControl(compact: false),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// زر حذف المنتج.
class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'حذف المنتج',
      onPressed: onPressed,
      visualDensity: VisualDensity.compact,
      style: IconButton.styleFrom(
        backgroundColor: const Color(0xFFF5F5F6),
        foregroundColor: const Color(0xFF7A7D82),
        minimumSize: const Size(34, 34),
      ),
      icon: const Icon(Icons.close_rounded, size: 18),
    );
  }
}

/// التحكم بالكمية.
class _QuantityControl extends StatelessWidget {
  const _QuantityControl({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    this.compact = false,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final buttonSize = compact ? 28.0 : 30.0;
    final valueWidth = compact ? 24.0 : 30.0;

    return Container(
      height: compact ? 34 : 36,
      padding: EdgeInsets.symmetric(horizontal: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QuantityButton(
            icon: Icons.remove_rounded,
            onPressed: onDecrease,
            size: buttonSize,
          ),
          SizedBox(
            width: valueWidth,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: Tween<double>(begin: 0.7, end: 1).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CartPage._textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          _QuantityButton(
            icon: Icons.add_rounded,
            primary: true,
            onPressed: onIncrease,
            size: buttonSize,
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onPressed,
    this.primary = false,
    this.size = 30,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final bool primary;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primary ? CartPage._primary : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: size < 30 ? 16 : 17,
            color: primary ? Colors.white : CartPage._textPrimary,
          ),
        ),
      ),
    );
  }
}

/// Checkout bar ثابتة.
class _CheckoutBar extends StatelessWidget {
  const _CheckoutBar({
    super.key,
    required this.totalQuantity,
    required this.totalPrice,
    required this.isSubmitting,
    required this.onSubmit,
  });
  final int totalQuantity;
  final double totalPrice;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 18,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'الإجمالي',
                          style: const TextStyle(
                            color: CartPage._textSecondary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F3F4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$totalQuantity',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, 0.3),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        '${_formatPrice(totalPrice)} ر.ي',
                        key: ValueKey(totalPrice),
                        style: const TextStyle(
                          color: CartPage._textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              SizedBox(
                height: 54,
                child: FilledButton(
                  onPressed: isSubmitting ? null : onSubmit,
                  style: FilledButton.styleFrom(
                    backgroundColor: CartPage._primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: CartPage._primary.withValues(
                      alpha: 0.65,
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: isSubmitting
                        ? const Row(
                            key: ValueKey('sending'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'جاري الإرسال',
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          )
                        : const Row(
                            key: ValueKey('submit'),
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'إرسال الطلبية',
                                style: TextStyle(fontWeight: FontWeight.w800),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_rounded, size: 19),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Empty state احترافية.
class _EmptyCart extends StatelessWidget {
  const _EmptyCart({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 550),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 20 * (1 - value)),
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: CartPage._primary.withValues(alpha: 0.08),
                      blurRadius: 40,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 58,
                    color: CartPage._primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'سلتك فارغة',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: CartPage._textPrimary,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: 10),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 300),
                child: Text(
                  'ابدأ بإضافة المنتجات التي تحتاجها، '
                  'وستظهر هنا جاهزة لإرسال طلبيتك.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: CartPage._textSecondary,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// حركة دخول موحدة للعناصر.
class _AppearAnimation extends StatelessWidget {
  const _AppearAnimation({
    required this.child,
    required this.index,
    this.baseDelay = 0,
  });

  final Widget child;
  final int index;
  final int baseDelay;

  @override
  Widget build(BuildContext context) {
    final milliseconds = 320 + baseDelay + ((index * 35).clamp(0, 180));

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: milliseconds),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _SupplierGroup {
  const _SupplierGroup({
    required this.key,
    required this.name,
    required this.items,
  });

  final String key;
  final String name;
  final List<CartItemEntity> items;
}

List<_SupplierGroup> _groupBySupplier(List<CartItemEntity> items) {
  final groups = <String, List<CartItemEntity>>{};
  final names = <String, String>{};

  for (final item in items) {
    final key = _supplierKey(item);
    final supplierName = item.isManual
        ? 'الأصناف اليدوية'
        : item.product.supplierName.trim();

    groups.putIfAbsent(key, () => <CartItemEntity>[]);

    groups[key]!.add(item);

    names[key] = supplierName.isNotEmpty ? supplierName : 'مورد غير محدد';
  }

  return groups.entries
      .map((entry) {
        return _SupplierGroup(
          key: entry.key,
          name: names[entry.key] ?? 'مورد غير محدد',
          items: List<CartItemEntity>.unmodifiable(entry.value),
        );
      })
      .toList(growable: false);
}

String _supplierKey(CartItemEntity item) {
  if (item.isManual) {
    return 'manual-items';
  }

  final supplierId = item.product.supplierId.trim();

  if (supplierId.isNotEmpty) {
    return 'id:$supplierId';
  }

  final supplierName = item.product.supplierName.trim().toLowerCase();

  if (supplierName.isNotEmpty) {
    return 'name:$supplierName';
  }

  return 'unknown:${item.product.id}';
}

String _formatPrice(double price) {
  if (price == price.truncateToDouble()) {
    return price.toStringAsFixed(0);
  }

  return price.toStringAsFixed(2);
}

String _itemsLabel(int quantity) {
  if (quantity == 1) {
    return 'منتج';
  }

  if (quantity >= 3 && quantity <= 10) {
    return 'منتجات';
  }

  return 'منتج';
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../business/domain/entities/business_entity.dart';
import '../../../business/presentation/pages/business_profile_edit_page.dart';
import '../../../business/presentation/providers/business_provider.dart';
import '../../../products/domain/entities/products_entity.dart';
import '../../../products/presentation/pages/add_product_page.dart';
import '../../../products/presentation/pages/product_details_page.dart';
import '../../../products/presentation/providers/products_provider.dart';
import '../../../products/presentation/widgets/product_image.dart';
import '../../../received_orders/domain/entities/received_order_entity.dart';
import '../../../received_orders/presentation/pages/received_orders_page.dart';
import '../../../received_orders/presentation/providers/received_orders_provider.dart';

enum AccountType { supplier, shopOwner }

extension AccountTypePresentation on AccountType {
  String get label {
    return switch (this) {
      AccountType.supplier => 'عضو نشاط تجاري',
      AccountType.shopOwner => 'عميل',
    };
  }

  IconData get icon {
    return switch (this) {
      AccountType.supplier => Icons.storefront_outlined,
      AccountType.shopOwner => Icons.person_outline_rounded,
    };
  }
}

class AccountPage extends ConsumerStatefulWidget {
  const AccountPage({
    super.key,
    this.displayName = 'مستخدم طلبيتك',
    this.businessName = 'لم تتم إضافة اسم النشاط',
    this.phoneNumber = 'غير مضاف',
    this.accountType = AccountType.shopOwner,
    this.onEditProfile,
    this.onOpenSettings,
    this.onOpenNotifications,
    this.onLogout,
  });

  final String displayName;
  final String businessName;
  final String phoneNumber;
  final AccountType accountType;
  final VoidCallback? onEditProfile;
  final VoidCallback? onOpenSettings;
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onLogout;

  @override
  ConsumerState<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends ConsumerState<AccountPage> {
  String? _selectedBusinessId;

  BusinessEntity? _selectedBusiness(List<BusinessEntity> businesses) {
    if (businesses.isEmpty) {
      return null;
    }

    if (_selectedBusinessId == null ||
        businesses.every((business) => business.id != _selectedBusinessId)) {
      _selectedBusinessId = businesses.first.id;
    }

    return businesses.firstWhere(
      (business) => business.id == _selectedBusinessId,
      orElse: () => businesses.first,
    );
  }

  Future<void> _openBusinessProfileSettings(BusinessEntity business) async {
    await Navigator.of(context).push<BusinessEntity>(
      MaterialPageRoute<BusinessEntity>(
        builder: (_) => BusinessProfileEditPage(business: business),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final businessController = ref.watch(businessControllerProvider);
    final businessState = businessController.state;
    final businesses = businessState.businesses;
    final selectedBusiness = _selectedBusiness(businesses);
    final productsAsync = selectedBusiness == null
        ? const AsyncValue<List<ProductEntity>>.data([])
        : ref.watch(supplierManagedProductsProvider(selectedBusiness.id));
    final productList = productsAsync.valueOrNull ?? const <ProductEntity>[];
    final ordersState = selectedBusiness == null
        ? null
        : ref
              .watch(receivedOrdersControllerProvider(selectedBusiness.id))
              .state;
    final orderList = ordersState?.orders ?? const <ReceivedOrderEntity>[];
    final user = ref.watch(authProvider).state.user;
    final displayName = user?.displayName.trim().isNotEmpty == true
        ? user!.displayName.trim()
        : widget.displayName;

    final phoneNumber =
        user?.contacts
            .where((contact) => contact.type.trim().toLowerCase() == 'phone')
            .firstOrNull
            ?.value
            .trim() ??
        widget.phoneNumber;

    final accountType = businesses.isNotEmpty
        ? AccountType.supplier
        : widget.accountType;
    final headerBusinessName = selectedBusiness?.name ?? widget.businessName;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('حسابي'),
        centerTitle: true,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          children: [
            if (businesses.length > 1)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedBusinessId,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    hint: const Text('اختر النشاط'),
                    items: businesses
                        .map(
                          (business) => DropdownMenuItem<String>(
                            value: business.id,
                            child: Text(
                              business.name,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedBusinessId = value);
                      }
                    },
                  ),
                ),
              ),
            if (selectedBusiness != null)
              _SupplierProfileHeader(
                business: selectedBusiness,
                productCount: productList.length,
                availableCount: productList
                    .where((product) => product.isAvailable)
                    .length,
                unavailableCount:
                    productList.length -
                    productList.where((product) => product.isAvailable).length,
              )
            else
              _ProfileCard(
                displayName: displayName,
                businessName: headerBusinessName,
                accountType: accountType,
                onEdit: () => _executeOrNotify(
                  context,
                  widget.onEditProfile,
                  'تعديل البيانات',
                ),
              ),
            const SizedBox(height: 16),
            if (selectedBusiness != null)
              _SupplierProfileActions(
                onAddProduct: () async => _openAddProduct(selectedBusiness),
                onOpenSettings: () =>
                    _openBusinessProfileSettings(selectedBusiness),
              )
            else
              _AccountSection(
                title: 'بيانات الحساب',
                children: [
                  _AccountOptionTile(
                    icon: Icons.phone_outlined,
                    title: 'رقم الهاتف',
                    subtitle: phoneNumber,
                    showArrow: false,
                  ),
                  _AccountOptionTile(
                    icon: accountType.icon,
                    title: 'نوع الحساب',
                    subtitle: accountType.label,
                    showArrow: false,
                  ),
                  _AccountOptionTile(
                    icon: Icons.person_outline_rounded,
                    title: 'البيانات الشخصية',
                    subtitle: 'الاسم ومعلومات النشاط',
                    onTap: () => _executeOrNotify(
                      context,
                      widget.onEditProfile,
                      'تعديل البيانات',
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (selectedBusiness != null)
              _SupplierContentTabs(
                products: productList,
                orders: orderList,
                onOpenProduct: (product) =>
                    _openProduct(product, selectedBusiness),
                onOpenOrder: () async {
                  await Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          ReceivedOrdersPage(businessId: selectedBusiness.id),
                    ),
                  );

                  if (!mounted) {
                    return;
                  }

                  await ref
                      .read(
                        receivedOrdersControllerProvider(selectedBusiness.id),
                      )
                      .loadReceivedOrders();
                },
                onAddProduct: () => _openAddProduct(selectedBusiness),
                onRefreshProducts: () async {
                  ref.invalidate(
                    supplierManagedProductsProvider(selectedBusiness.id),
                  );

                  await ref.read(
                    supplierManagedProductsProvider(selectedBusiness.id).future,
                  );
                },
                onRefreshOrders: () async {
                  await ref
                      .read(
                        receivedOrdersControllerProvider(selectedBusiness.id),
                      )
                      .loadReceivedOrders();
                },
                onAdvanceOrder: (order) async {
                  await ref
                      .read(
                        receivedOrdersControllerProvider(selectedBusiness.id),
                      )
                      .updateFulfillment(order: order);
                },
              )
            else if (businessState.hasFailure)
              _AccountSection(
                title: 'مساحة الأعمال',
                children: [
                  _AccountOptionTile(
                    icon: Icons.refresh_rounded,
                    title: 'تعذر تحميل الأنشطة',
                    subtitle:
                        businessState.errorMessage ?? 'اضغط لإعادة المحاولة',
                    onTap: () =>
                        ref.read(businessControllerProvider).loadBusinesses(),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            _AccountSection(
              title: 'الإعدادات',
              children: [
                _AccountOptionTile(
                  icon: Icons.notifications_none_rounded,
                  title: 'الإشعارات',
                  subtitle: 'إدارة تنبيهات المنتجات والطلبات',
                  onTap: () => _executeOrNotify(
                    context,
                    widget.onOpenNotifications,
                    'الإشعارات',
                  ),
                ),
                _AccountOptionTile(
                  icon: Icons.settings_outlined,
                  title: 'إعدادات التطبيق',
                  subtitle: 'إدارة تفضيلات الحساب والتطبيق',
                  onTap: () => _executeOrNotify(
                    context,
                    widget.onOpenSettings,
                    'إعدادات التطبيق',
                  ),
                ),
                _AccountOptionTile(
                  icon: Icons.security_outlined,
                  title: 'الأمان والحماية',
                  subtitle: 'إدارة كلمة المرور والخصوصية',
                  onTap: () => _showComingSoon(context, 'الأمان والحماية'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _LogoutButton(
              onPressed: () =>
                  _executeOrNotify(context, widget.onLogout, 'تسجيل الخروج'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openAddProduct(BusinessEntity business) async {
    await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => AddProductPage(
          supplierId: business.id,
          supplierName: business.name,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    ref.invalidate(supplierManagedProductsProvider(business.id));
  }

  Future<void> _openProduct(
    ProductEntity product,
    BusinessEntity business,
  ) async {
    await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => ProductDetailsPage(
          product: product,
          managedBusinessId: business.id,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    ref.invalidate(supplierManagedProductsProvider(business.id));
  }

  void _executeOrNotify(
    BuildContext context,
    VoidCallback? action,
    String featureName,
  ) {
    if (action != null) {
      action();
      return;
    }

    _showComingSoon(context, featureName);
  }

  void _showComingSoon(BuildContext context, String featureName) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text('$featureName ستتوفر قريبًا.'),
        ),
      );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({
    required this.displayName,
    required this.businessName,
    required this.accountType,
    required this.onEdit,
  });

  final String displayName;
  final String businessName;
  final AccountType accountType;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 32,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  businessName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          accountType.icon,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          accountType.label,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'تعديل البيانات',
            onPressed: onEdit,
            icon: const Icon(Icons.edit_outlined),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

class _SupplierProfileHeader extends StatelessWidget {
  const _SupplierProfileHeader({
    required this.business,
    required this.productCount,
    required this.availableCount,
    required this.unavailableCount,
  });

  final BusinessEntity business;
  final int productCount;
  final int availableCount;
  final int unavailableCount;

  String get _initial {
    final normalized = business.name.trim();
    if (normalized.isEmpty) {
      return 'م';
    }
    final first = normalized.characters.first;
    return first.isEmpty ? 'م' : first;
  }

  @override
  Widget build(BuildContext context) {
    final description = _cleanText(business.description);
    final location = _cleanText(business.location);

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.primaryLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _initial,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      business.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    if (location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _ProfileStatTile(
                  label: 'منتجات',
                  value: '$productCount',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileStatTile(
                  label: 'متاحة',
                  value: '$availableCount',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ProfileStatTile(
                  label: 'غير متاحة',
                  value: '$unavailableCount',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String? _cleanText(String? value) {
    final normalized = value?.trim() ?? '';
    return normalized.isEmpty ? null : normalized;
  }
}

class _ProfileStatTile extends StatelessWidget {
  const _ProfileStatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SupplierProfileActions extends StatelessWidget {
  const _SupplierProfileActions({
    required this.onAddProduct,
    required this.onOpenSettings,
  });

  final VoidCallback onAddProduct;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onAddProduct,
            icon: const Icon(Icons.add_rounded),
            label: const Text('إضافة منتج'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onOpenSettings,
            icon: const Icon(Icons.settings_outlined),
            label: const Text('الإعدادات'),
          ),
        ),
      ],
    );
  }
}

class _SupplierContentTabs extends StatelessWidget {
  const _SupplierContentTabs({
    required this.products,
    required this.orders,
    required this.onOpenProduct,
    required this.onOpenOrder,
    required this.onAddProduct,
    required this.onRefreshProducts,
    required this.onRefreshOrders,
    required this.onAdvanceOrder,
  });

  final List<ProductEntity> products;
  final List<ReceivedOrderEntity> orders;
  final Future<void> Function(ProductEntity) onOpenProduct;
  final Future<void> Function() onOpenOrder;
  final VoidCallback onAddProduct;
  final Future<void> Function() onRefreshProducts;
  final Future<void> Function() onRefreshOrders;
  final Future<void> Function(ReceivedOrderEntity) onAdvanceOrder;

  @override
  Widget build(BuildContext context) {
    final productHeight = products.isEmpty
        ? 300.0
        : ((products.length / 3).ceil() * 170.0) + 24.0;

    final orderHeight = orders.isEmpty ? 260.0 : (orders.length * 170.0) + 24.0;

    final tabHeight = productHeight > orderHeight ? productHeight : orderHeight;

    return DefaultTabController(
      length: 3,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.grid_view_rounded), text: 'المنتجات'),
                Tab(icon: Icon(Icons.view_agenda_rounded), text: 'العرض'),
                Tab(icon: Icon(Icons.receipt_long_rounded), text: 'الطلبات'),
              ],
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
            ),
            SizedBox(
              height: tabHeight,
              child: TabBarView(
                children: [
                  _ManagedGrid(
                    products: products,
                    onOpenProduct: onOpenProduct,
                    onAddProduct: onAddProduct,
                    onRefresh: onRefreshProducts,
                  ),
                  _ProductShowcase(
                    products: products,
                    onOpenProduct: onOpenProduct,
                    onAddProduct: onAddProduct,
                    onRefresh: onRefreshProducts,
                  ),
                  _OrdersTab(
                    orders: orders,
                    onOpenOrder: onOpenOrder,
                    onAdvanceOrder: onAdvanceOrder,
                    onRefresh: onRefreshOrders,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  const _OrdersTab({
    required this.orders,
    required this.onOpenOrder,
    required this.onAdvanceOrder,
    required this.onRefresh,
  });

  final List<ReceivedOrderEntity> orders;
  final Future<void> Function() onOpenOrder;
  final Future<void> Function(ReceivedOrderEntity) onAdvanceOrder;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: const [
            SizedBox(height: 24),
            Icon(
              Icons.receipt_long_outlined,
              size: 56,
              color: AppColors.textHint,
            ),
            SizedBox(height: 14),
            Text('لا توجد طلبات مستلمة حاليًا', textAlign: TextAlign.center),
            SizedBox(height: 6),
            Text(
              'ستظهر طلبات هذا النشاط هنا فور وصولها.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        itemCount: orders.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = orders[index];

          return _OrderSummaryCard(
            order: order,
            onAdvance: () => onAdvanceOrder(order),
            onOpen: onOpenOrder,
          );
        },
      ),
    );
  }
}

class _OrderSummaryCard extends StatelessWidget {
  const _OrderSummaryCard({
    required this.order,
    required this.onAdvance,
    required this.onOpen,
  });

  final ReceivedOrderEntity order;
  final Future<void> Function() onAdvance;
  final Future<void> Function() onOpen;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _orderFulfillmentLabel(order);
    final nextStatusLabel = _nextFulfillmentLabel(order);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'طلب #${_shortOrderId(order.orderId)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
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
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          if (order.createdAt != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Text(
                  _formatOrderDate(order.createdAt!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.shopping_bag_outlined,
                size: 16,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                '${order.items.length} عنصر',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onOpen,
                  icon: const Icon(Icons.visibility_outlined),
                  label: const Text('عرض الطلب'),
                ),
              ),
              if (nextStatusLabel != null) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAdvance,
                    icon: const Icon(Icons.arrow_forward_rounded),
                    label: Text(nextStatusLabel),
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

String _orderFulfillmentLabel(ReceivedOrderEntity order) {
  final status = order.fulfillmentStatus;

  if (status == null) {
    return 'بانتظار الرد';
  }

  return switch (status) {
    ReceivedOrderFulfillmentStatus.confirmed => 'مؤكد',
    ReceivedOrderFulfillmentStatus.preparing => 'قيد التجهيز',
    ReceivedOrderFulfillmentStatus.readyForDelivery => 'جاهز للتسليم',
    ReceivedOrderFulfillmentStatus.outForDelivery => 'خارج للتوصيل',
    ReceivedOrderFulfillmentStatus.delivered => 'مكتمل',
  };
}

String? _nextFulfillmentLabel(ReceivedOrderEntity order) {
  final next = order.nextFulfillmentStatus;

  if (next == null) {
    return null;
  }

  return switch (next) {
    ReceivedOrderFulfillmentStatus.confirmed => 'قبول الطلب',
    ReceivedOrderFulfillmentStatus.preparing => 'بدء التجهيز',
    ReceivedOrderFulfillmentStatus.readyForDelivery => 'تجهيز الطلب',
    ReceivedOrderFulfillmentStatus.outForDelivery => 'تسليم الطلب',
    ReceivedOrderFulfillmentStatus.delivered => 'تم التسليم',
  };
}

String _shortOrderId(String value) {
  final normalized = value.trim();

  if (normalized.length <= 8) {
    return normalized;
  }

  return normalized.substring(0, 8);
}

String _formatOrderDate(DateTime value) {
  final day = value.day.toString().padLeft(2, '0');
  final month = value.month.toString().padLeft(2, '0');
  final year = value.year;
  final hour = value.hour.toString().padLeft(2, '0');
  final minute = value.minute.toString().padLeft(2, '0');

  return '$day/$month/$year - $hour:$minute';
}

class _ManagedGrid extends StatelessWidget {
  const _ManagedGrid({
    required this.products,
    required this.onOpenProduct,
    required this.onAddProduct,
    required this.onRefresh,
  });

  final List<ProductEntity> products;
  final Future<void> Function(ProductEntity) onOpenProduct;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            const Text(
              'لا توجد منتجات في هذا النشاط',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة أول منتج لعرضه في ملفك التجاري.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة منتج'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(),
      child: GridView.builder(
        padding: const EdgeInsets.all(12),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.72,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _ProductGridTile(
            product: product,
            onTap: () => onOpenProduct(product),
          );
        },
      ),
    );
  }
}

class _ProductShowcase extends StatelessWidget {
  const _ProductShowcase({
    required this.products,
    required this.onOpenProduct,
    required this.onAddProduct,
    required this.onRefresh,
  });

  final List<ProductEntity> products;
  final Future<void> Function(ProductEntity) onOpenProduct;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => onRefresh(),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(
              Icons.view_agenda_rounded,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            const Text('لا توجد عناصر للعرض بعد', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            const Text(
              'أضف منتجًا ليظهر في هذا العرض.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة منتج'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => onRefresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ShowcaseCard(
            product: product,
            onTap: () => onOpenProduct(product),
          );
        },
      ),
    );
  }
}

class _ProductGridTile extends StatelessWidget {
  const _ProductGridTile({required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = _syncLabel(product);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProductImage(imageUrl: product.displayImagePath),
                  ),
                  if (!product.isAvailable)
                    PositionedDirectional(
                      end: 8,
                      top: 8,
                      child: _StatusBadge(
                        label: 'غير متاح',
                        color: AppColors.background,
                        textColor: AppColors.textPrimary,
                      ),
                    ),
                  if (product.needsSync)
                    PositionedDirectional(
                      start: 8,
                      top: 8,
                      child: _StatusBadge(
                        label: statusLabel,
                        color: product.syncStatus == ProductSyncStatus.failed
                            ? AppColors.error
                            : AppColors.warning,
                        textColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${product.price.toStringAsFixed(0)} ر.ي',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShowcaseCard extends StatelessWidget {
  const _ShowcaseCard({required this.product, required this.onTap});

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = product.discount > 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 260,
              width: double.infinity,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ProductImage(imageUrl: product.displayImagePath),
                  ),
                  if (!product.isAvailable)
                    PositionedDirectional(
                      start: 12,
                      top: 12,
                      child: _StatusBadge(
                        label: 'غير متاح',
                        color: AppColors.background,
                        textColor: AppColors.textPrimary,
                      ),
                    ),
                  if (product.needsSync)
                    PositionedDirectional(
                      end: 12,
                      top: 12,
                      child: _StatusBadge(
                        label: _syncLabel(product),
                        color: product.syncStatus == ProductSyncStatus.failed
                            ? AppColors.error
                            : AppColors.warning,
                        textColor: Colors.white,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '${product.price.toStringAsFixed(0)} ر.ي',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(width: 8),
                      if (hasDiscount)
                        Text(
                          '${product.discount.toStringAsFixed(0)}٪ خصم',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.isAvailable ? 'متاح الآن' : 'غير متاح حاليًا',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: product.isAvailable
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

String _syncLabel(ProductEntity product) {
  switch (product.syncStatus) {
    case ProductSyncStatus.pendingCreate:
    case ProductSyncStatus.pendingUpdate:
      return 'بانتظار المزامنة';
    case ProductSyncStatus.pendingDelete:
      return 'بانتظار الحذف';
    case ProductSyncStatus.failed:
      return 'تعذر التحديث';
    case ProductSyncStatus.synced:
      return 'مزامنة';
  }
}

class _AccountSection extends StatelessWidget {
  const _AccountSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _AccountOptionTile extends StatelessWidget {
  const _AccountOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.showArrow = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (showArrow)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
          ],
        ),
      ),
    );
  }
}

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.logout_rounded),
      label: const Text('تسجيل الخروج'),
    );
  }
}

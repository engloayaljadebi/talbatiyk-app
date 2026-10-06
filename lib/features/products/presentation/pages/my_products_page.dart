import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/products_entity.dart';
import '../providers/products_provider.dart';
import '../widgets/product_image.dart';
import 'add_product_page.dart';
import 'product_details_page.dart';

class MyProductsPage extends ConsumerStatefulWidget {
  const MyProductsPage({
    super.key,
    required this.businessId,
    required this.businessName,
    this.businessDescription,
    this.businessLocation,
  });

  final String businessId;
  final String businessName;
  final String? businessDescription;
  final String? businessLocation;

  @override
  ConsumerState<MyProductsPage> createState() => _MyProductsPageState();
}

class _MyProductsPageState extends ConsumerState<MyProductsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(supplierManagedProductsProvider(widget.businessId));
    await ref.read(supplierManagedProductsProvider(widget.businessId).future);
  }

  Future<void> _openProduct(ProductEntity product) async {
    await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => ProductDetailsPage(
          product: product,
          managedBusinessId: widget.businessId,
        ),
      ),
    );

    ref.invalidate(supplierManagedProductsProvider(widget.businessId));
  }

  Future<void> _createProduct() async {
    await Navigator.of(context).push<Object?>(
      MaterialPageRoute<Object?>(
        builder: (_) => AddProductPage(
          supplierId: widget.businessId,
          supplierName: widget.businessName,
        ),
      ),
    );

    ref.invalidate(supplierManagedProductsProvider(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(
      supplierManagedProductsProvider(widget.businessId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: const Text('منتجاتي'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'إضافة منتج',
            onPressed: _createProduct,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => _LoadingProfileShell(businessName: widget.businessName),
        error: (error, stackTrace) {
          return _ProfileErrorState(
            businessName: widget.businessName,
            businessId: widget.businessId,
            onRetry: () {
              ref.invalidate(
                supplierManagedProductsProvider(widget.businessId),
              );
            },
            onAddProduct: _createProduct,
          );
        },
        data: (products) {
          final businessStats = _buildStats(products);

          return SafeArea(
            child: Column(
              children: [
                _SupplierProfileHeader(
                  businessName: widget.businessName,
                  description: _extractDescription(),
                  location: _extractLocation(),
                  productCount: products.length,
                  stats: businessStats,
                ),
                const SizedBox(height: 14),
                _SupplierProfileActions(onAddProduct: _createProduct),
                const SizedBox(height: 12),
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant,
                  indicatorColor: Theme.of(context).colorScheme.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  tabs: const [
                    Tab(
                      icon: Icon(Icons.grid_view_rounded),
                      child: Text('المنتجات'),
                    ),
                    Tab(
                      icon: Icon(Icons.view_agenda_rounded),
                      child: Text('العرض'),
                    ),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _ProductsGridTab(
                        products: products,
                        onRefresh: _refresh,
                        onProductTap: _openProduct,
                        onCreateProduct: _createProduct,
                      ),
                      _ProductShowcaseTab(
                        products: products,
                        onRefresh: _refresh,
                        onProductTap: _openProduct,
                        onCreateProduct: _createProduct,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String? _extractDescription() {
    final value = (widget.businessDescription ?? '').trim();
    return value.isEmpty ? null : value;
  }

  String? _extractLocation() {
    final value = (widget.businessLocation ?? '').trim();
    return value.isEmpty ? null : value;
  }

  List<_ProfileStat> _buildStats(List<ProductEntity> products) {
    final availableCount = products
        .where((product) => product.isAvailable)
        .length;
    final unavailableCount = products.length - availableCount;

    return [
      _ProfileStat(label: 'منتجات', value: '${products.length}'),
      _ProfileStat(label: 'متاحة', value: '$availableCount'),
      _ProfileStat(label: 'غير متاحة', value: '$unavailableCount'),
    ];
  }
}

class _ProfileStat {
  const _ProfileStat({required this.label, required this.value});

  final String label;
  final String value;
}

class _SupplierProfileHeader extends StatelessWidget {
  const _SupplierProfileHeader({
    required this.businessName,
    required this.description,
    required this.location,
    required this.productCount,
    required this.stats,
  });

  final String businessName;
  final String? description;
  final String? location;
  final int productCount;
  final List<_ProfileStat> stats;

  String get _initial {
    final normalized = businessName.trim();
    if (normalized.isEmpty) {
      return 'م';
    }
    final first = normalized[0];
    return first.isEmpty ? 'م' : first;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _initial,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      businessName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (description != null &&
                        description!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (location != null && location!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
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
          _SupplierProfileStats(stats: stats),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '$productCount منتج',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SupplierProfileStats extends StatelessWidget {
  const _SupplierProfileStats({required this.stats});

  final List<_ProfileStat> stats;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      stat.value,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      stat.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _SupplierProfileActions extends StatelessWidget {
  const _SupplierProfileActions({required this.onAddProduct});

  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              onPressed: onAddProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة منتج'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductsGridTab extends StatelessWidget {
  const _ProductsGridTab({
    required this.products,
    required this.onRefresh,
    required this.onProductTap,
    required this.onCreateProduct,
  });

  final List<ProductEntity> products;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ProductEntity) onProductTap;
  final VoidCallback onCreateProduct;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            const SizedBox(height: 18),
            Icon(
              Icons.inventory_2_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد منتجات حتى الآن',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'ابدأ بإضافة أول منتج لعرضه في ملفك التجاري.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreateProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة منتج'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 360 ? 3 : 4;

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
            itemCount: products.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.7,
            ),
            itemBuilder: (context, index) {
              final product = products[index];
              return _ManagedProductGridTile(
                key: ValueKey('managed-product-grid-tile-${product.id}'),
                product: product,
                onTap: () => onProductTap(product),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductShowcaseTab extends StatelessWidget {
  const _ProductShowcaseTab({
    required this.products,
    required this.onRefresh,
    required this.onProductTap,
    required this.onCreateProduct,
  });

  final List<ProductEntity> products;
  final Future<void> Function() onRefresh;
  final Future<void> Function(ProductEntity) onProductTap;
  final VoidCallback onCreateProduct;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Icon(
              Icons.view_agenda_rounded,
              size: 72,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد عناصر للعرض بعد',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const Text(
              'أضف منتجًا ليظهر في هذا العرض.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onCreateProduct,
              icon: const Icon(Icons.add_rounded),
              label: const Text('إضافة منتج'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        itemCount: products.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final product = products[index];
          return _ShowcaseCard(
            product: product,
            onTap: () => onProductTap(product),
          );
        },
      ),
    );
  }
}

class _ManagedProductGridTile extends StatelessWidget {
  const _ManagedProductGridTile({
    super.key,
    required this.product,
    required this.onTap,
  });

  final ProductEntity product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
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
                          color: theme.colorScheme.surfaceContainerHighest,
                          textColor: theme.colorScheme.onSurface,
                        ),
                      ),
                    if (product.needsSync)
                      PositionedDirectional(
                        start: 8,
                        top: 8,
                        child: _StatusBadge(
                          label: _syncLabel(product),
                          color: product.syncStatus == ProductSyncStatus.failed
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.tertiaryContainer,
                          textColor:
                              product.syncStatus == ProductSyncStatus.failed
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${product.price.toStringAsFixed(0)} ر.ي',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
    final theme = Theme.of(context);
    final hasDiscount = product.discount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 290,
                width: double.infinity,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductImage(imageUrl: product.displayImagePath),
                    ),
                    PositionedDirectional(
                      start: 12,
                      top: 12,
                      child: _StatusBadge(
                        label: product.isAvailable ? 'متاح' : 'غير متاح',
                        color: product.isAvailable
                            ? theme.colorScheme.primaryContainer
                            : theme.colorScheme.surfaceContainerHighest,
                        textColor: product.isAvailable
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (product.needsSync)
                      PositionedDirectional(
                        end: 12,
                        top: 12,
                        child: _StatusBadge(
                          label: _syncLabel(product),
                          color: product.syncStatus == ProductSyncStatus.failed
                              ? theme.colorScheme.errorContainer
                              : theme.colorScheme.tertiaryContainer,
                          textColor:
                              product.syncStatus == ProductSyncStatus.failed
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onTertiaryContainer,
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          '${product.price.toStringAsFixed(0)} ر.ي',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (hasDiscount)
                          Text(
                            '${product.discount.toStringAsFixed(0)}% خصم',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.isAvailable ? 'متاح الآن' : 'غير متاح حاليًا',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: product.isAvailable
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
      return 'تمت المزامنة';
  }
}

class _LoadingProfileShell extends StatelessWidget {
  const _LoadingProfileShell({required this.businessName});

  final String businessName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  width: 74,
                  height: 74,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 170,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 12,
                        width: 220,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 54,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 16),
          const Expanded(child: Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }
}

class _ProfileErrorState extends StatelessWidget {
  const _ProfileErrorState({
    required this.businessName,
    required this.businessId,
    required this.onRetry,
    required this.onAddProduct,
  });

  final String businessName;
  final String businessId;
  final VoidCallback onRetry;
  final VoidCallback onAddProduct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'تعذر تحميل منتجات النشاط. حاول مرة أخرى.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: onRetry,
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('إعادة المحاولة'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onAddProduct,
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('إضافة منتج'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

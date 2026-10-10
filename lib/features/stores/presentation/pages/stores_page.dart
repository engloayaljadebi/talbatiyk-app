import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../supplier_discovery/domain/entities/supplier_candidate_entity.dart';
import '../../../supplier_discovery/presentation/providers/supplier_discovery_provider.dart';
import '../../../account/presentation/pages/account_page.dart';

/// Customer-facing list of supplier business accounts.
/// Reads the existing generated API /suppliers via SupplierDiscoveryController.
class StoresPage extends ConsumerStatefulWidget {
  const StoresPage({super.key});

  @override
  ConsumerState<StoresPage> createState() => _StoresPageState();
}

class _StoresPageState extends ConsumerState<StoresPage> {
  final TextEditingController _query = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(supplierDiscoveryControllerProvider).loadSuppliers();
      }
    });
  }

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = ref.watch(supplierDiscoveryControllerProvider);
    final state = controller.state;
    final needle = _query.text.trim().toLowerCase();
    final stores = state.suppliers
        .where((store) => store.name.toLowerCase().contains(needle))
        .toList(growable: false);

    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          child: TextField(
            key: const ValueKey<String>('stores-search'),
            controller: _query,
            onChanged: (_) => setState(() {}),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: 'ابحث عن متجر بالاسم',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'مسح البحث',
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () {
                        _query.clear();
                        setState(() {});
                      },
                    ),
              filled: true,
              fillColor: const Color(0xFFF4F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (state.isFromCache)
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                Icon(Icons.offline_bolt_outlined, size: 17),
                SizedBox(width: 8),
                Expanded(
                  child: Text('هذه قائمة محفوظة؛ قد تكون البيانات قديمة.'),
                ),
              ],
            ),
          ),
        Expanded(
          child: state.isLoading && state.suppliers.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : state.errorMessage != null
              ? _StoresFeedback(
                  message: state.errorMessage!,
                  onRetry: controller.loadSuppliers,
                )
              : stores.isEmpty
              ? _StoresFeedback(
                  message: needle.isEmpty
                      ? 'لا توجد متاجر متاحة حاليًا'
                      : 'لا توجد متاجر مطابقة لبحثك',
                  onRetry: needle.isEmpty ? controller.loadSuppliers : null,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    await controller.loadSuppliers();
                  },
                  child: ListView.separated(
                    key: const ValueKey<String>('stores-list'),
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
                    itemCount: stores.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) =>
                        _StoreTile(store: stores[index]),
                  ),
                ),
        ),
      ],
    );
  }
}

class _StoreTile extends StatelessWidget {
  const _StoreTile({required this.store});
  final SupplierCandidateEntity store;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        key: ValueKey<String>('store-${store.id}'),
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => AccountPage(viewedStore: store),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 54,
                width: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.storefront_rounded,
                  color: Color(0xFFE53935),
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'عرض الملف التجاري والمنتجات',
                      style: TextStyle(fontSize: 12, color: Color(0xFF71717A)),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_left_rounded, color: Color(0xFF71717A)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoresFeedback extends StatelessWidget {
  const _StoresFeedback({required this.message, this.onRetry});
  final String message;
  final Future<bool> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.store_mall_directory_outlined,
              size: 52,
              color: Color(0xFF9CA3AF),
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  onRetry!();
                },
                child: const Text('إعادة المحاولة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

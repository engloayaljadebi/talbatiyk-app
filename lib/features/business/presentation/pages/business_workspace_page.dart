import 'package:flutter/material.dart';

import '../../../products/presentation/pages/add_product_page.dart';
import '../../../products/presentation/pages/my_products_page.dart';
import '../../domain/entities/business_entity.dart';
import 'business_profile_edit_page.dart';

final class BusinessWorkspacePage extends StatefulWidget {
  const BusinessWorkspacePage({required this.businesses, super.key});

  final List<BusinessEntity> businesses;

  @override
  State<BusinessWorkspacePage> createState() => _BusinessWorkspacePageState();
}

final class _BusinessWorkspacePageState extends State<BusinessWorkspacePage> {
  late List<BusinessEntity> _businesses;

  @override
  void initState() {
    super.initState();

    _businesses = List<BusinessEntity>.of(widget.businesses);
  }

  void _replaceBusiness(BusinessEntity updated) {
    final index = _businesses.indexWhere(
      (business) => business.id == updated.id,
    );

    if (index < 0) {
      return;
    }

    setState(() {
      _businesses[index] = updated;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مساحة الأعمال'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _businesses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final business = _businesses[index];

          return Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                ListTile(
                  key: ValueKey<String>(
                    'manage-business-profile-${business.id}',
                  ),
                  leading: const Icon(Icons.storefront_outlined),
                  title: const Text('بيانات النشاط'),
                  subtitle: const Text('تعديل الاسم والوصف والهوية القانونية'),
                  trailing: const Icon(Icons.edit_outlined, size: 19),
                  onTap: () async {
                    final updated = await Navigator.of(context)
                        .push<BusinessEntity>(
                          MaterialPageRoute<BusinessEntity>(
                            builder: (_) =>
                                BusinessProfileEditPage(business: business),
                          ),
                        );

                    if (updated != null && mounted) {
                      _replaceBusiness(updated);
                    }
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  key: ValueKey<String>('manage-products-${business.id}'),
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: const Text('منتجاتي'),
                  subtitle: const Text('عرض المنتجات وتعديلها وحذفها'),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                  onTap: () async {
                    await Navigator.of(context).push<Object?>(
                      MaterialPageRoute<Object?>(
                        builder: (_) => MyProductsPage(
                          businessId: business.id,
                          businessName: business.name,
                          businessDescription: business.description,
                          businessLocation: business.location,
                        ),
                      ),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  key: ValueKey<String>('publish-product-${business.id}'),
                  leading: const Icon(Icons.add_box_outlined),
                  title: const Text('نشر منتج'),
                  subtitle: const Text('إضافة منتج جديد وإتاحته للمستخدمين'),
                  trailing: const Icon(Icons.cloud_upload_outlined),
                  onTap: () async {
                    await Navigator.of(context).push<Object?>(
                      MaterialPageRoute<Object?>(
                        builder: (_) => AddProductPage(
                          supplierId: business.id,
                          supplierName: business.name,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

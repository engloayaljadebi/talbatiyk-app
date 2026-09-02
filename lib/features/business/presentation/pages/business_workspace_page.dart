import 'package:flutter/material.dart';

import '../../../received_orders/presentation/pages/received_orders_page.dart';
import '../../domain/entities/business_entity.dart';

final class BusinessWorkspacePage extends StatelessWidget {
  const BusinessWorkspacePage({required this.businesses, super.key});

  final List<BusinessEntity> businesses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مساحة الأعمال'), centerTitle: true),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: businesses.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final business = businesses[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: Text(business.name),
              subtitle: const Text('الطلبات المستلمة'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ReceivedOrdersPage(businessId: business.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

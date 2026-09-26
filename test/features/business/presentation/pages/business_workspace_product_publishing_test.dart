import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/presentation/pages/business_workspace_page.dart';
import 'package:talbatiyk/features/products/presentation/pages/add_product_page.dart';

void main() {
  testWidgets(
    'business workspace opens product publishing with the real business identity',
    (tester) async {
      const business = BusinessEntity(
        id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        name: 'Real Supplier Business',
      );

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BusinessWorkspacePage(businesses: <BusinessEntity>[business]),
          ),
        ),
      );

      final publishAction = find.byKey(
        const ValueKey('publish-product-aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
      );

      expect(publishAction, findsOneWidget);

      await tester.tap(publishAction);
      await tester.pumpAndSettle();

      expect(find.byType(AddProductPage), findsOneWidget);

      final page = tester.widget<AddProductPage>(find.byType(AddProductPage));

      expect(page.supplierId, 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa');

      expect(page.supplierName, 'Real Supplier Business');

      expect(find.text('نشر المنتج'), findsOneWidget);
    },
  );
}

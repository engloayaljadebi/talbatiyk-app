import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/presentation/pages/business_workspace_page.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/presentation/pages/my_products_page.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';

void main() {
  testWidgets(
    'Business Workspace opens My Products with real Business identity',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      addTearDown(database.close);

      const business = BusinessEntity(
        id: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
        name: 'Real Supplier Business',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
              const _EmptyRemote(),
            ),
          ],
          child: const MaterialApp(
            home: BusinessWorkspacePage(businesses: <BusinessEntity>[business]),
          ),
        ),
      );

      final action = find.byKey(
        const ValueKey('manage-products-aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'),
      );

      expect(action, findsOneWidget);

      await tester.tap(action);
      await tester.pumpAndSettle();

      expect(find.byType(MyProductsPage), findsOneWidget);

      final page = tester.widget<MyProductsPage>(find.byType(MyProductsPage));

      expect(page.businessId, business.id);
      expect(page.businessName, business.name);

      expect(find.text('منتجاتي'), findsOneWidget);
    },
  );
}

final class _EmptyRemote implements ProductsSupplierManagementRemoteDataSource {
  const _EmptyRemote();

  @override
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    return const <ProductModel>[];
  }
}

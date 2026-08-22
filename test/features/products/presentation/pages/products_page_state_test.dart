import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/presentation/pages/products_page.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';
import 'package:talbatiyk/features/products/presentation/state/products_state.dart';
import 'package:talbatiyk/features/products/presentation/widgets/product_card.dart';

void main() {
  testWidgets(
    'preserves discovery state after opening product details and going back',
    (tester) async {
      final container = ProviderContainer(
        overrides: [
          productDiscoveryDataSourceProvider.overrideWithValue(
            const _FakeProductsDataSource([
              ProductModel(
                id: 'product-1',
                supplierId: 'supplier-1',
                supplierName: 'مورد سامسونج',
                name: 'شاحن سريع',
                price: 4500,
                imageUrl: '',
                category: 'شواحن',
                brand: 'Samsung',
                isAvailable: true,
                description: 'شاحن سريع مع ضمان سنة',
              ),
              ProductModel(
                id: 'product-2',
                supplierId: 'supplier-2',
                supplierName: 'مورد أبل',
                name: 'سماعة لاسلكية',
                price: 15000,
                imageUrl: '',
                category: 'سماعات',
                brand: 'Apple',
                isAvailable: false,
              ),
            ]),
          ),
        ],
      );

      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(home: ProductsPage()),
        ),
      );

      // نستخدم نفس Product Discovery flow الفعلي،
      // ونستبدل مصدر البيانات فقط حتى يبقى الاختبار معزولًا ومستقرًا.
      await tester.pumpAndSettle();

      final controller = container.read(productDiscoveryProvider);

      expect(controller.state.products, hasLength(2));

      // نطبق البحث من TextField الفعلي حتى نختبر UI وController معًا.
      final searchField = find.byType(TextField);

      await tester.enterText(searchField, 'شاحن');
      await tester.pump();

      expect(controller.state.search, 'شاحن');
      expect(controller.state.products.single.id, 'product-1');

      // نطبق Filter حقيقي مع إبقاء نطاق السعر كاملًا،
      // حتى يركز الاختبار على Category / Brand / Availability.
      controller.applyFilters(
        category: 'شواحن',
        brand: 'Samsung',
        availability: ProductAvailabilityFilter.available,
        minPrice: controller.minimumPrice,
        maxPrice: controller.maximumPrice,
      );

      // نغيّر وضع العرض أيضًا للتأكد أن حالة الشاشة كاملة تبقى محفوظة.
      controller.changeView();

      await tester.pump();

      expect(controller.hasActiveFilters, isTrue);
      expect(controller.state.selectedCategory, 'شواحن');
      expect(controller.state.selectedBrand, 'Samsung');
      expect(
        controller.state.availability,
        ProductAvailabilityFilter.available,
      );
      expect(controller.state.isGrid, isTrue);
      expect(controller.state.products.single.id, 'product-1');

      // نفتح Product Details من نفس ProductCard المستخدم في Discovery.
      await tester.tap(find.byType(ProductCard));
      await tester.pumpAndSettle();

      expect(find.text('تفاصيل المنتج'), findsOneWidget);
      expect(find.text('شاحن سريع'), findsWidgets);

      // الرجوع يجب أن يعيدنا لنفس ProductsPage وحالتها الحالية.
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(ProductsPage), findsOneWidget);

      // Gate 2.2 يتطلب بقاء Discovery state مستقرة بعد الرجوع.
      expect(controller.state.search, 'شاحن');
      expect(controller.state.selectedCategory, 'شواحن');
      expect(controller.state.selectedBrand, 'Samsung');
      expect(
        controller.state.availability,
        ProductAvailabilityFilter.available,
      );
      expect(controller.state.isGrid, isTrue);
      expect(controller.state.products.single.id, 'product-1');

      // لا يكفي بقاء Riverpod state؛ يجب أن يبقى نص البحث ظاهرًا أيضًا.
      final textField = tester.widget<TextField>(find.byType(TextField));

      expect(textField.controller?.text, 'شاحن');
      expect(find.text('شاحن سريع'), findsOneWidget);
      expect(find.text('سماعة لاسلكية'), findsNothing);
    },
  );
}

final class _FakeProductsDataSource implements ProductsDataSource {
  const _FakeProductsDataSource(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getProducts() async => products;
}

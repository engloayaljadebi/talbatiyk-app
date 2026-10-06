import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/business/domain/entities/business_entity.dart';
import 'package:talbatiyk/features/business/presentation/pages/business_workspace_page.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';
import 'package:talbatiyk/features/cart/presentation/providers/cart_provider.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';
import 'package:talbatiyk/features/products/presentation/pages/add_product_page.dart';
import 'package:talbatiyk/features/products/presentation/pages/my_products_page.dart';
import 'package:talbatiyk/features/products/presentation/pages/product_details_page.dart';
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

  testWidgets(
    'supplier profile renders business description, location and counts',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      const business = BusinessEntity(
        id: 'business-42',
        name: 'متجر النخبة',
        description: 'منتجات عصرية ومميزة للمنزل.',
        location: 'الرياض، المملكة العربية السعودية',
      );

      final remote = _RemoteWithProducts(<ProductModel>[
        const ProductModel(
          id: 'product-1',
          name: 'خزانة صغيرة',
          price: 180,
          imageUrl: '',
          category: 'أثاث',
          brand: 'النخبة',
          isAvailable: true,
          description: 'خزانة حديثة',
          supplierId: 'business-42',
          supplierName: 'متجر النخبة',
          quantity: 9,
          serverVersion: 1,
          syncStatus: ProductSyncStatus.synced,
        ),
        const ProductModel(
          id: 'product-2',
          name: 'كرسي عمل',
          price: 240,
          imageUrl: '',
          category: 'أثاث',
          brand: 'النخبة',
          isAvailable: false,
          description: 'كرسي مريح',
          supplierId: 'business-42',
          supplierName: 'متجر النخبة',
          quantity: 3,
          serverVersion: 1,
          syncStatus: ProductSyncStatus.pendingUpdate,
        ),
      ]);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
              remote,
            ),
            cartProvider.overrideWith((ref) => CartController()),
          ],
          child: MaterialApp(
            home: MyProductsPage(
              businessId: business.id,
              businessName: business.name,
              businessDescription: business.description,
              businessLocation: business.location,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('متجر النخبة'), findsWidgets);
      expect(find.text('منتجات عصرية ومميزة للمنزل.'), findsOneWidget);
      expect(find.text('الرياض، المملكة العربية السعودية'), findsOneWidget);
      expect(find.text('2 منتج'), findsWidgets);
    },
  );

  testWidgets(
    'product grid item opens ProductDetailsPage with managed business',
    (tester) async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(database.close);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(database),
            supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
              _RemoteWithProducts(<ProductModel>[
                const ProductModel(
                  id: 'grid-product',
                  name: 'مقعد مريّح',
                  price: 320,
                  imageUrl: '',
                  category: 'أثاث',
                  brand: 'النخبة',
                  isAvailable: true,
                  description: 'مقعد ممتاز',
                  supplierId: 'business-grid',
                  supplierName: 'متجر النخبة',
                  quantity: 2,
                  serverVersion: 1,
                  syncStatus: ProductSyncStatus.synced,
                ),
              ]),
            ),
            cartProvider.overrideWith((ref) => CartController()),
          ],
          child: const MaterialApp(
            home: MyProductsPage(
              businessId: 'business-grid',
              businessName: 'متجر النخبة',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await tester.tap(
        find.byKey(const ValueKey('managed-product-grid-tile-grid-product')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailsPage), findsOneWidget);

      final detailsPage = tester.widget<ProductDetailsPage>(
        find.byType(ProductDetailsPage),
      );
      expect(detailsPage.managedBusinessId, 'business-grid');
    },
  );

  testWidgets('add product action passes business identity', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
            const _EmptyRemote(),
          ),
        ],
        child: const MaterialApp(
          home: MyProductsPage(
            businessId: 'business-create',
            businessName: 'متجر النخبة',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.text('إضافة منتج').first);
    await tester.pumpAndSettle();

    expect(find.byType(AddProductPage), findsOneWidget);

    final page = tester.widget<AddProductPage>(find.byType(AddProductPage));
    expect(page.supplierId, 'business-create');
    expect(page.supplierName, 'متجر النخبة');
  });

  testWidgets('pending sync and unavailable states are user-friendly', (
    tester,
  ) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await database
        .into(database.productRecords)
        .insert(
          ProductRecordsCompanion.insert(
            id: 'sync-late',
            supplierId: 'business-sync',
            supplierName: 'متجر النخبة',
            name: 'طاولة',
            price: 199,
            category: const Value('أثاث'),
            brand: const Value('النخبة'),
            description: const Value('طاولة طعام'),
            quantity: const Value(4),
            isAvailable: const Value(false),
            discount: const Value(0),
            rating: const Value(0),
            colorsJson: const Value('[]'),
            localImagePath: const Value.absent(),
            remoteImageUrl: const Value.absent(),
            serverVersion: const Value(1),
            syncStatus: const Value('pendingUpdate'),
            syncError: const Value.absent(),
            syncAttempts: const Value(0),
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            deletedAt: const Value.absent(),
          ),
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
          home: MyProductsPage(
            businessId: 'business-sync',
            businessName: 'متجر النخبة',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('بانتظار المزامنة'), findsOneWidget);
    expect(find.text('غير متاح'), findsOneWidget);
  });

  testWidgets('empty state keeps profile context visible', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
            const _EmptyRemote(),
          ),
        ],
        child: const MaterialApp(
          home: MyProductsPage(
            businessId: 'business-empty',
            businessName: 'متجر فارغ',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('متجر فارغ'), findsWidgets);
    expect(find.text('لا توجد منتجات حتى الآن'), findsOneWidget);
    expect(find.text('إضافة منتج').first, findsOneWidget);
  });

  testWidgets('narrow RTL layout does not overflow', (tester) async {
    final database = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(database.close);

    await tester.binding.setSurfaceSize(const Size(320, 700));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
            _RemoteWithProducts(<ProductModel>[
              const ProductModel(
                id: 'narrow-1',
                name: 'منتج طويل جدًا جدًا جدًا جدًا جدًا جدًا',
                price: 150,
                imageUrl: '',
                category: 'أثاث',
                brand: 'النخبة',
                isAvailable: true,
                description: 'وصف طويل جدًا جدًا جدًا جدًا جدًا جدًا',
                supplierId: 'business-narrow',
                supplierName: 'متجر ضيق',
                quantity: 1,
                serverVersion: 1,
                syncStatus: ProductSyncStatus.synced,
              ),
            ]),
          ),
        ],
        child: const MaterialApp(
          home: MyProductsPage(
            businessId: 'business-narrow',
            businessName: 'متجر ضيق',
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(tester.takeException(), null);
    expect(
      find.text('منتج طويل جدًا جدًا جدًا جدًا جدًا جدًا'),
      findsOneWidget,
    );
  });
}

final class _EmptyRemote implements ProductsSupplierManagementRemoteDataSource {
  const _EmptyRemote();

  @override
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    return const <ProductModel>[];
  }
}

final class _RemoteWithProducts
    implements ProductsSupplierManagementRemoteDataSource {
  const _RemoteWithProducts(this.products);

  final List<ProductModel> products;

  @override
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    return products;
  }
}

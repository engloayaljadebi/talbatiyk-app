import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/core/database/app_database.dart';
import 'package:talbatiyk/core/database/database_provider.dart';
import 'package:talbatiyk/features/auth/domain/entities/auth_entity.dart';
import 'package:talbatiyk/features/auth/domain/services/account_session_fence.dart';
import 'package:talbatiyk/features/auth/presentation/providers/account_session_fence_provider.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/presentation/providers/products_provider.dart';

final _providerTestSession = AuthSessionEntity(
  user: AuthUserEntity(
    id: 'supplier-provider-test-owner',
    username: 'supplier-provider-test',
    displayName: 'Supplier Provider Test',
    status: 'active',
    lastLoginAt: null,
    contacts: const <AuthContactEntity>[],
  ),
);

final _providerTestFence = AccountSessionFence(() => _providerTestSession);
void main() {
  test(
    'supplier management provider stores the Business server snapshot locally',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountSessionFenceProvider.overrideWithValue(_providerTestFence),
          supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
            _FakeRemote(
              products: <ProductModel>[
                _product(id: 'remote-1', businessId: 'business-1', version: 5),
              ],
            ),
          ),
        ],
      );

      addTearDown(container.dispose);
      addTearDown(database.close);

      final products = await container.read(
        supplierManagedProductsProvider('business-1').future,
      );

      expect(products, hasLength(1));
      expect(products.single.id, 'remote-1');
      expect(products.single.serverVersion, 5);

      final cached = await container
          .read(productsLocalDataSourceProvider)
          .getProducts();

      expect(cached, hasLength(1));
      expect(cached.single.id, 'remote-1');
    },
  );

  test(
    'supplier management provider uses Business local data for connection failure',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountSessionFenceProvider.overrideWithValue(_providerTestFence),
          supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
            _FakeRemote(
              error: DioException(
                requestOptions: RequestOptions(
                  path: '/businesses/business-1/products',
                ),
                type: DioExceptionType.connectionError,
              ),
            ),
          ),
        ],
      );

      addTearDown(container.dispose);
      addTearDown(database.close);

      await container
          .read(productsLocalDataSourceProvider)
          .upsertSyncedProduct(
            _product(id: 'local-1', businessId: 'business-1', version: 2),
          );

      final products = await container.read(
        supplierManagedProductsProvider('business-1').future,
      );

      expect(products, hasLength(1));
      expect(products.single.id, 'local-1');
    },
  );

  test(
    'supplier management provider never exposes private cache after HTTP 403',
    () async {
      final database = AppDatabase.forTesting(NativeDatabase.memory());

      final request = RequestOptions(path: '/businesses/business-1/products');

      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          accountSessionFenceProvider.overrideWithValue(_providerTestFence),
          supplierProductManagementRemoteDataSourceProvider.overrideWithValue(
            _FakeRemote(
              error: DioException(
                requestOptions: request,
                response: Response<Object?>(
                  requestOptions: request,
                  statusCode: 403,
                ),
                type: DioExceptionType.badResponse,
              ),
            ),
          ),
        ],
      );

      addTearDown(container.dispose);
      addTearDown(database.close);

      await container
          .read(productsLocalDataSourceProvider)
          .upsertSyncedProduct(
            _product(id: 'private-local', businessId: 'business-1', version: 2),
          );

      await expectLater(
        container.read(supplierManagedProductsProvider('business-1').future),
        throwsA(isA<DioException>()),
      );
    },
  );
}

final class _FakeRemote implements ProductsSupplierManagementRemoteDataSource {
  _FakeRemote({this.products = const <ProductModel>[], this.error});

  final List<ProductModel> products;
  final Object? error;

  @override
  Future<List<ProductModel>> getBusinessProducts(String businessId) async {
    final currentError = error;

    if (currentError != null) {
      throw currentError;
    }

    return List<ProductModel>.unmodifiable(products);
  }
}

ProductModel _product({
  required String id,
  required String businessId,
  required int version,
}) {
  return ProductModel(
    id: id,
    supplierId: businessId,
    supplierName: 'Managed Supplier',
    name: 'Managed Product',
    price: 100,
    imageUrl: '',
    serverVersion: version,
    category: 'Tests',
    brand: 'Talbatiyk',
    isAvailable: true,
    quantity: 5,
    createdAt: DateTime.utc(2026, 10, 6),
    updatedAt: DateTime.utc(2026, 10, 6),
  );
}

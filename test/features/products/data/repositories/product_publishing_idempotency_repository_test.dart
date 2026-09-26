import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:talbatiyk/features/products/data/datasources/products_datasource.dart';
import 'package:talbatiyk/features/products/data/models/products_model.dart';
import 'package:talbatiyk/features/products/data/repositories/products_repository_impl.dart';
import 'package:talbatiyk/features/products/domain/entities/products_entity.dart';

void main() {
  test(
    'ambiguous failure then repository recreation reuses the same publish key',
    () async {
      const clientProduct = ProductModel(
        id: '11111111-aaaa-4111-8111-111111111111',
        supplierId: '22222222-bbbb-4222-8222-222222222222',
        supplierName: 'Supplier',
        name: 'Restart Safe Product',
        price: 2500,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        description: 'Same logical publication',
        quantity: 3,
      );

      const serverProduct = ProductModel(
        id: '33333333-cccc-4333-8333-333333333333',
        supplierId: '22222222-bbbb-4222-8222-222222222222',
        supplierName: 'Supplier',
        name: 'Restart Safe Product',
        price: 2500,
        imageUrl: 'https://example.test/product.jpg',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        description: 'Same logical publication',
        quantity: 3,
        syncStatus: ProductSyncStatus.synced,
      );

      final local = _AttemptStoreFake();

      final failingRemote = _IdempotentRemoteFake(
        serverProduct: serverProduct,
        failFirst: true,
      );

      final firstRepository = ProductsRepositoryImpl(
        local,
        createDataSource: failingRemote,
      );

      await expectLater(
        () => firstRepository.createProduct(_toEntity(clientProduct)),
        throwsA(isA<DioException>()),
      );

      expect(failingRemote.keys, hasLength(1));

      final durableKey = failingRemote.keys.single;

      expect(local.attempt?.idempotencyKey, durableKey);

      /*
       * New repository object simulates application/repository recreation.
       * The durable attempt store remains the same persisted state.
       */
      final succeedingRemote = _IdempotentRemoteFake(
        serverProduct: serverProduct,
      );

      final recreatedRepository = ProductsRepositoryImpl(
        local,
        createDataSource: succeedingRemote,
      );

      await recreatedRepository.getProducts();

      expect(succeedingRemote.keys, <String>[durableKey]);

      expect(local.syncedProduct?.id, serverProduct.id);

      expect(local.attempt, isNull);

      expect(local.productCreateOutboxWrites, 0);
    },
  );
  test(
    'server 500 keeps publish retryable and replay reuses same key',
    () async {
      const clientProduct = ProductModel(
        id: '10101010-aaaa-4101-8101-101010101010',
        supplierId: '20202020-bbbb-4202-8202-202020202020',
        supplierName: 'Supplier',
        name: 'Retryable Product',
        price: 1700,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        quantity: 2,
      );

      const serverProduct = ProductModel(
        id: '30303030-cccc-4303-8303-303030303030',
        supplierId: '20202020-bbbb-4202-8202-202020202020',
        supplierName: 'Supplier',
        name: 'Retryable Product',
        price: 1700,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        quantity: 2,
        syncStatus: ProductSyncStatus.synced,
      );

      final local = _AttemptStoreFake();

      final failingRemote = _StatusFailRemoteFake(statusCode: 500);

      final repository = ProductsRepositoryImpl(
        local,
        createDataSource: failingRemote,
      );

      await expectLater(
        () => repository.createProduct(_toEntity(clientProduct)),
        throwsA(isA<DioException>()),
      );

      expect(failingRemote.keys, hasLength(1));

      final durableKey = failingRemote.keys.single;

      expect(local.attempt?.status, ProductPublishAttemptStatus.retrying);

      final replayRemote = _IdempotentRemoteFake(serverProduct: serverProduct);

      final recreatedRepository = ProductsRepositoryImpl(
        local,
        createDataSource: replayRemote,
      );

      await recreatedRepository.getProducts();

      expect(replayRemote.keys, <String>[durableKey]);

      expect(local.syncedProduct?.id, serverProduct.id);

      expect(local.attempt, isNull);

      expect(local.productCreateOutboxWrites, 0);
    },
  );

  test(
    'definitive 409 and 422 become permanent and are not auto replayed',
    () async {
      for (final statusCode in <int>[409, 422]) {
        const clientProduct = ProductModel(
          id: '40404040-dddd-4404-8404-404040404040',
          supplierId: '50505050-eeee-4505-8505-505050505050',
          supplierName: 'Supplier',
          name: 'Rejected Product',
          price: 1800,
          imageUrl: '',
          category: 'Electronics',
          brand: 'Talbatiyk',
          isAvailable: true,
          quantity: 1,
        );

        const unusedServerProduct = ProductModel(
          id: '60606060-ffff-4606-8606-606060606060',
          supplierId: '50505050-eeee-4505-8505-505050505050',
          supplierName: 'Supplier',
          name: 'Rejected Product',
          price: 1800,
          imageUrl: '',
          category: 'Electronics',
          brand: 'Talbatiyk',
          isAvailable: true,
          quantity: 1,
        );

        final local = _AttemptStoreFake();

        final rejectedRemote = _StatusFailRemoteFake(statusCode: statusCode);

        final repository = ProductsRepositoryImpl(
          local,
          createDataSource: rejectedRemote,
        );

        await expectLater(
          () => repository.createProduct(_toEntity(clientProduct)),
          throwsA(isA<DioException>()),
        );

        expect(
          local.attempt?.status,
          ProductPublishAttemptStatus.permanentFailure,
          reason: 'HTTP $statusCode must be permanent.',
        );

        expect(rejectedRemote.keys, hasLength(1));

        final succeedingRemote = _IdempotentRemoteFake(
          serverProduct: unusedServerProduct,
        );

        final recreatedRepository = ProductsRepositoryImpl(
          local,
          createDataSource: succeedingRemote,
        );

        await recreatedRepository.getProducts();

        /*
         * Permanent failures are retained for diagnosis/manual action
         * but must not be replayed automatically.
         */
        expect(
          succeedingRemote.keys,
          isEmpty,
          reason: 'HTTP $statusCode must not auto replay.',
        );

        expect(
          local.attempt?.status,
          ProductPublishAttemptStatus.permanentFailure,
        );

        expect(local.productCreateOutboxWrites, 0);
      }
    },
  );

  test(
    'local reconciliation failure retains attempt and later replay uses same key',
    () async {
      const clientProduct = ProductModel(
        id: '70707070-aaaa-4707-8707-707070707070',
        supplierId: '80808080-bbbb-4808-8808-808080808080',
        supplierName: 'Supplier',
        name: 'Reconciliation Product',
        price: 1900,
        imageUrl: '',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        quantity: 5,
      );

      const serverProduct = ProductModel(
        id: '90909090-cccc-4909-8909-909090909090',
        supplierId: '80808080-bbbb-4808-8808-808080808080',
        supplierName: 'Supplier',
        name: 'Reconciliation Product',
        price: 1900,
        imageUrl: 'https://example.test/reconciled.jpg',
        category: 'Electronics',
        brand: 'Talbatiyk',
        isAvailable: true,
        quantity: 5,
        syncStatus: ProductSyncStatus.synced,
      );

      final local = _AttemptStoreFake(failUpsertOnce: true);

      final firstRemote = _IdempotentRemoteFake(serverProduct: serverProduct);

      final repository = ProductsRepositoryImpl(
        local,
        createDataSource: firstRemote,
      );

      /*
       * Laravel succeeds.
       * First local reconciliation is deliberately failed.
       */
      final result = await repository.createProduct(_toEntity(clientProduct));

      expect(result.id, serverProduct.id);

      expect(firstRemote.keys, hasLength(1));

      final durableKey = firstRemote.keys.single;

      /*
       * Since local canonical storage failed, the attempt must remain.
       */
      expect(local.attempt, isNotNull);

      expect(local.syncedProduct, isNull);

      final replayRemote = _IdempotentRemoteFake(serverProduct: serverProduct);

      final recreatedRepository = ProductsRepositoryImpl(
        local,
        createDataSource: replayRemote,
      );

      await recreatedRepository.getProducts();

      expect(replayRemote.keys, <String>[durableKey]);

      expect(local.syncedProduct?.id, serverProduct.id);

      expect(local.attempt, isNull);

      expect(local.productCreateOutboxWrites, 0);
    },
  );
}

ProductEntity _toEntity(ProductModel model) {
  return ProductEntity(
    id: model.id,
    supplierId: model.supplierId,
    supplierName: model.supplierName,
    name: model.name,
    price: model.price,
    imageUrl: model.imageUrl,
    localImagePath: model.localImagePath,
    category: model.category,
    brand: model.brand,
    isAvailable: model.isAvailable,
    description: model.description,
    colors: model.colors,
    quantity: model.quantity,
    discount: model.discount,
    rating: model.rating,
    syncStatus: model.syncStatus,
    syncError: model.syncError,
    createdAt: model.createdAt,
    updatedAt: model.updatedAt,
  );
}

final class _IdempotentRemoteFake
    implements ProductsCreateDataSource, ProductsIdempotentCreateDataSource {
  _IdempotentRemoteFake({required this.serverProduct, this.failFirst = false});

  final ProductModel serverProduct;
  final bool failFirst;

  final List<String> keys = <String>[];

  @override
  Future<ProductModel> createProduct(ProductModel product) {
    throw UnsupportedError(
      'Legacy createProduct is not valid for Product Publishing.',
    );
  }

  @override
  Future<ProductModel> createProductIdempotently(
    ProductModel product, {
    required String idempotencyKey,
  }) async {
    keys.add(idempotencyKey);

    if (failFirst && keys.length == 1) {
      throw DioException(
        requestOptions: RequestOptions(
          path: '/businesses/${product.supplierId}/products',
        ),
        type: DioExceptionType.receiveTimeout,
      );
    }

    return serverProduct;
  }
}

final class _AttemptStoreFake
    implements
        ProductsDataSource,
        ProductsSyncedStoreDataSource,
        ProductsPublishAttemptDataSource {
  _AttemptStoreFake({this.failUpsertOnce = false});

  final bool failUpsertOnce;

  bool _upsertFailed = false;

  ProductPublishAttempt? attempt;
  ProductModel? syncedProduct;

  int productCreateOutboxWrites = 0;

  @override
  Future<List<ProductModel>> getProducts() async {
    if (syncedProduct == null) {
      return const [];
    }

    return <ProductModel>[syncedProduct!];
  }

  @override
  Future<ProductModel> upsertSyncedProduct(ProductModel product) async {
    if (failUpsertOnce && !_upsertFailed) {
      _upsertFailed = true;

      throw StateError('simulated local reconciliation failure');
    }

    syncedProduct = product;
    return product;
  }

  @override
  Future<ProductPublishAttempt> preparePublishAttempt({
    required ProductModel product,
    required String idempotencyKey,
  }) async {
    final existing = attempt;

    if (existing != null) {
      return existing;
    }

    final created = ProductPublishAttempt(
      idempotencyKey: idempotencyKey,
      product: product,
      status: ProductPublishAttemptStatus.pending,
      attempts: 0,
    );

    attempt = created;

    return created;
  }

  @override
  Future<List<ProductPublishAttempt>> getRetryablePublishAttempts() async {
    final current = attempt;

    if (current == null ||
        current.status == ProductPublishAttemptStatus.permanentFailure) {
      return const [];
    }

    return <ProductPublishAttempt>[current];
  }

  @override
  Future<void> markPublishAttemptRetry({
    required String idempotencyKey,
    required int attempts,
    required Object error,
    required DateTime nextAttemptAt,
  }) async {
    final current = attempt;

    if (current == null) {
      return;
    }

    attempt = ProductPublishAttempt(
      idempotencyKey: current.idempotencyKey,
      product: current.product,
      status: ProductPublishAttemptStatus.retrying,
      attempts: attempts,
      lastError: error.toString(),
      /*
       * Keep immediately retryable in this focused fake so repository
       * recreation can exercise the replay path without waiting 30 seconds.
       */
      nextAttemptAt: DateTime.now().toUtc(),
    );
  }

  @override
  Future<void> markPublishAttemptPermanentFailure({
    required String idempotencyKey,
    required int attempts,
    required Object error,
  }) async {
    final current = attempt;

    if (current == null) {
      return;
    }

    attempt = ProductPublishAttempt(
      idempotencyKey: current.idempotencyKey,
      product: current.product,
      status: ProductPublishAttemptStatus.permanentFailure,
      attempts: attempts,
      lastError: error.toString(),
    );
  }

  @override
  Future<void> completePublishAttempt(String idempotencyKey) async {
    if (attempt?.idempotencyKey == idempotencyKey) {
      attempt = null;
    }
  }
}

final class _StatusFailRemoteFake
    implements ProductsCreateDataSource, ProductsIdempotentCreateDataSource {
  _StatusFailRemoteFake({required this.statusCode});

  final int statusCode;

  final List<String> keys = <String>[];

  @override
  Future<ProductModel> createProduct(ProductModel product) {
    throw UnsupportedError(
      'Legacy createProduct is not valid for Product Publishing.',
    );
  }

  @override
  Future<ProductModel> createProductIdempotently(
    ProductModel product, {
    required String idempotencyKey,
  }) async {
    keys.add(idempotencyKey);

    final requestOptions = RequestOptions(
      path: '/businesses/${product.supplierId}/products',
    );

    throw DioException(
      requestOptions: requestOptions,
      response: Response<Object?>(
        requestOptions: requestOptions,
        statusCode: statusCode,
      ),
      type: DioExceptionType.badResponse,
    );
  }
}

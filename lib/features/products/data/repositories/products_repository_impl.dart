import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/products_entity.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_datasource.dart';
import '../mappers/products_mapper.dart';
import '../models/products_model.dart';

/// تنفيذ المستودع الذي يعزل الواجهة وطبقة الأعمال عن مصادر البيانات.
class ProductsRepositoryImpl implements ProductsRepository {
  ProductsRepositoryImpl(this.dataSource, {this.createDataSource});

  final ProductsDataSource dataSource;

  /// مصدر إنشاء مستقل اختياري.
  ///
  /// يسمح لمسار الإنشاء بالنشر Online بينما تبقى update/delete على المصدر
  /// المحلي الحالي إلى أن تتوفر عقود API مستقلة لهما.
  final ProductsCreateDataSource? createDataSource;

  bool _isSyncingPendingPublishes = false;
  ProductsCreateDataSource get _productCreateDataSource {
    final source = createDataSource ?? dataSource;

    if (source is! ProductsCreateDataSource) {
      throw UnsupportedError('مصدر المنتجات الحالي لا يدعم إنشاء المنتجات.');
    }

    return source;
  }

  /// يعيد مصدر البيانات القابل للكتابة بعد التأكد من دعمه للعمليات.
  ProductsWritableDataSource get _writableDataSource {
    final source = dataSource;

    if (source is! ProductsWritableDataSource) {
      throw UnsupportedError(
        'مصدر المنتجات الحالي لا يدعم إنشاء المنتجات أو تعديلها أو حذفها.',
      );
    }

    // أصبح التحويل آمنًا بعد التحقق السابق.
    return source as ProductsWritableDataSource;
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    /*
     * A repository reconstructed after process restart can recover durable
     * ambiguous Product publications before serving the local supplier list.
     *
     * Recovery failure must not break the read path.
     */
    try {
      await _syncPendingPublishes();
    } catch (error, stackTrace) {
      developer.log(
        'Pending Product publication recovery failed.',
        name: 'talbatiyk.products.publishing',
        error: error,
        stackTrace: stackTrace,
      );
    }

    final models = await dataSource.getProducts();

    return List<ProductEntity>.unmodifiable(
      models.map(ProductsMapper.toEntity),
    );
  }

  @override
  Future<ProductEntity> createProduct(ProductEntity product) async {
    final ProductModel model = ProductsMapper.fromEntity(product);

    final ProductsCreateDataSource? remoteSource = createDataSource;
    final ProductsDataSource localSource = dataSource;

    /*
     * Online Product Publishing requires BOTH:
     *
     * - a remote source that accepts an explicit durable key;
     * - a local Drift store that persists the attempt before POST.
     */
    if (remoteSource is ProductsIdempotentCreateDataSource &&
        localSource is ProductsPublishAttemptDataSource) {
      /*
       * Explicit typed aliases are intentional.
       *
       * Do not rely on analyzer promotion across the two independent
       * datasource interfaces.
       */
      final ProductsIdempotentCreateDataSource idempotentRemote =
          remoteSource as ProductsIdempotentCreateDataSource;

      final ProductsPublishAttemptDataSource attemptStore =
          localSource as ProductsPublishAttemptDataSource;

      /*
       * Recover older ambiguous publications first.
       */
      await _syncPendingPublishes();

      final ProductPublishAttempt attempt = await attemptStore
          .preparePublishAttempt(
            product: model,

            /*
         * This candidate key is used ONLY if Drift has no attempt for the
         * current clientProductId.
         *
         * Existing logical attempts return their durable stored key.
         */
            idempotencyKey: Uuid().v4(),
          );

      if (attempt.status == ProductPublishAttemptStatus.permanentFailure) {
        throw StateError(
          'تعذر إعادة محاولة نشر هذا المنتج لأن الخادم رفض المحاولة السابقة '
          'بشكل نهائي. ابدأ عملية نشر جديدة.',
        );
      }

      late final ProductModel serverProduct;

      try {
        serverProduct = await idempotentRemote.createProductIdempotently(
          attempt.product,
          idempotencyKey: attempt.idempotencyKey,
        );
      } catch (error, stackTrace) {
        await _recordPublishFailureWithoutMaskingOriginal(
          store: attemptStore,
          attempt: attempt,
          error: error,
          stackTrace: stackTrace,
        );

        rethrow;
      }

      await _reconcileAcceptedPublish(
        attemptStore: attemptStore,
        attempt: attempt,
        serverProduct: serverProduct,
      );

      return ProductsMapper.toEntity(serverProduct);
    }

    /*
     * Legacy local/offline create flow remains unchanged for repositories
     * that are not configured for online Product Publishing.
     */
    final ProductModel savedModel = await _productCreateDataSource
        .createProduct(model);

    if (createDataSource != null &&
        dataSource is ProductsSyncedStoreDataSource) {
      final ProductsSyncedStoreDataSource syncedStore =
          dataSource as ProductsSyncedStoreDataSource;

      try {
        await syncedStore.upsertSyncedProduct(savedModel);
      } catch (error, stackTrace) {
        /*
         * Laravel already accepted the Product.
         * Local reconciliation failure must not cause another POST.
         */
        developer.log(
          'Product was published by Laravel but local reconciliation failed.',
          name: 'talbatiyk.products.publishing',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return ProductsMapper.toEntity(savedModel);
  }

  @override
  Future<ProductEntity> updateProduct(ProductEntity product) async {
    // نحول المنتج المعدّل إلى نموذج بيانات.
    final model = ProductsMapper.fromEntity(product);

    // نحفظ التعديل محليًا ونسجل عملية المزامنة المناسبة.
    final updatedModel = await _writableDataSource.updateProduct(model);

    return ProductsMapper.toEntity(updatedModel);
  }

  @override
  Future<void> deleteProduct(String productId) {
    // ينفذ المصدر المحلي الحذف المنطقي أو النهائي حسب حالة المزامنة.
    return _writableDataSource.deleteProduct(productId);
  }

  Future<void> _syncPendingPublishes() async {
    if (_isSyncingPendingPublishes) {
      return;
    }

    final ProductsCreateDataSource? remoteSource = createDataSource;

    final ProductsDataSource localSource = dataSource;

    if (remoteSource is! ProductsIdempotentCreateDataSource ||
        localSource is! ProductsPublishAttemptDataSource) {
      return;
    }

    final ProductsIdempotentCreateDataSource idempotentRemote =
        remoteSource as ProductsIdempotentCreateDataSource;

    final ProductsPublishAttemptDataSource attemptStore =
        localSource as ProductsPublishAttemptDataSource;

    _isSyncingPendingPublishes = true;

    try {
      final List<ProductPublishAttempt> attempts = await attemptStore
          .getRetryablePublishAttempts();

      for (final ProductPublishAttempt attempt in attempts) {
        try {
          final ProductModel serverProduct = await idempotentRemote
              .createProductIdempotently(
                attempt.product,
                idempotencyKey: attempt.idempotencyKey,
              );

          await _reconcileAcceptedPublish(
            attemptStore: attemptStore,
            attempt: attempt,
            serverProduct: serverProduct,
          );
        } catch (error, stackTrace) {
          await _recordPublishFailureWithoutMaskingOriginal(
            store: attemptStore,
            attempt: attempt,
            error: error,
            stackTrace: stackTrace,
          );
        }
      }
    } finally {
      _isSyncingPendingPublishes = false;
    }
  }

  Future<void> _reconcileAcceptedPublish({
    required ProductsPublishAttemptDataSource attemptStore,
    required ProductPublishAttempt attempt,
    required ProductModel serverProduct,
  }) async {
    final ProductsDataSource localSource = dataSource;

    if (localSource is ProductsSyncedStoreDataSource) {
      final ProductsSyncedStoreDataSource syncedStore =
          localSource as ProductsSyncedStoreDataSource;

      try {
        /*
         * Persist the canonical server identity first.
         *
         * The durable attempt is removed ONLY after this succeeds.
         */
        await syncedStore.upsertSyncedProduct(serverProduct);

        await attemptStore.completePublishAttempt(attempt.idempotencyKey);
      } catch (error, stackTrace) {
        /*
         * Keep the durable attempt.
         *
         * A later replay sends the SAME Idempotency-Key and Laravel returns
         * the same canonical Product rather than creating another Product.
         */
        developer.log(
          'Product was accepted remotely but local reconciliation failed; '
          'durable idempotent attempt retained.',
          name: 'talbatiyk.products.publishing',
          error: error,
          stackTrace: stackTrace,
        );
      }

      return;
    }

    /*
     * A repository without a synced local Product store has nothing further
     * to reconcile.
     */
    await attemptStore.completePublishAttempt(attempt.idempotencyKey);
  }

  Future<void> _recordPublishFailureWithoutMaskingOriginal({
    required ProductsPublishAttemptDataSource store,
    required ProductPublishAttempt attempt,
    required Object error,
    required StackTrace stackTrace,
  }) async {
    final attempts = attempt.attempts + 1;

    try {
      if (_isPermanentPublishFailure(error)) {
        await store.markPublishAttemptPermanentFailure(
          idempotencyKey: attempt.idempotencyKey,
          attempts: attempts,
          error: error,
        );
      } else {
        await store.markPublishAttemptRetry(
          idempotencyKey: attempt.idempotencyKey,
          attempts: attempts,
          error: error,
          nextAttemptAt: DateTime.now().toUtc().add(
            _publishRetryDelay(attempts),
          ),
        );
      }
    } catch (persistenceError, persistenceStackTrace) {
      /*
       * Never replace the original network/API failure with a secondary
       * Drift bookkeeping failure.
       */
      developer.log(
        'Failed to persist Product publication retry state.',
        name: 'talbatiyk.products.publishing',
        error: persistenceError,
        stackTrace: persistenceStackTrace,
      );
    }

    developer.log(
      'Product publication failed or had an ambiguous remote outcome.',
      name: 'talbatiyk.products.publishing',
      error: error,
      stackTrace: stackTrace,
    );
  }

  bool _isPermanentPublishFailure(Object error) {
    if (error is! DioException || error.type != DioExceptionType.badResponse) {
      return false;
    }

    final statusCode = error.response?.statusCode;

    if (statusCode == null) {
      return false;
    }

    /*
     * 401 may recover after session restoration.
     * 408 / 429 / 5xx are retryable or ambiguous.
     */
    return statusCode >= 400 &&
        statusCode < 500 &&
        statusCode != 401 &&
        statusCode != 408 &&
        statusCode != 429;
  }

  Duration _publishRetryDelay(int attempts) {
    switch (attempts) {
      case 1:
        return const Duration(seconds: 30);
      case 2:
        return const Duration(minutes: 1);
      case 3:
        return const Duration(minutes: 5);
      default:
        return const Duration(minutes: 15);
    }
  }

  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final products = await getProducts();
    final normalizedQuery = query.trim().toLowerCase();

    return products.where((item) {
      return item.name.toLowerCase().contains(normalizedQuery) ||
          item.brand.toLowerCase().contains(normalizedQuery) ||
          item.category.toLowerCase().contains(normalizedQuery) ||
          item.description.toLowerCase().contains(normalizedQuery);
    }).toList();
  }

  @override
  Future<List<ProductEntity>> filterProducts({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
    bool? available,
  }) async {
    var products = await getProducts();

    if (category != null && category.isNotEmpty) {
      products = products.where((item) {
        return item.category == category;
      }).toList();
    }

    if (brand != null && brand.isNotEmpty) {
      products = products.where((item) {
        return item.brand == brand;
      }).toList();
    }

    if (minPrice != null) {
      products = products.where((item) {
        return item.price >= minPrice;
      }).toList();
    }

    if (maxPrice != null) {
      products = products.where((item) {
        return item.price <= maxPrice;
      }).toList();
    }

    if (available != null) {
      products = products.where((item) {
        return item.isAvailable == available;
      }).toList();
    }

    return products;
  }
}

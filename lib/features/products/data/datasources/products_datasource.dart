import '../models/products_model.dart';

/// Read contract shared by local, remote, and composed product sources.
abstract interface class ProductsDataSource {
  Future<List<ProductModel>> getProducts();
}

/// Local cache contract used by customer Product Discovery.
///
/// Cache writes represent server snapshots only. They must never create
/// Outbox operations or overwrite local product mutations waiting for sync.
abstract interface class ProductsCacheDataSource {
  Future<List<ProductModel>> getCachedProducts();

  Future<void> replaceCachedProducts(List<ProductModel> products);
}

/// Dedicated contract for creating a product.
///
/// A create implementation may publish directly to the server and does not
/// imply support for update or delete.
abstract interface class ProductsCreateDataSource {
  Future<ProductModel> createProduct(ProductModel product);
}

/// Local lifecycle state for one logical online Product publication.
enum ProductPublishAttemptStatus { pending, retrying, permanentFailure }

/// Durable Product publication recovered from Drift.
///
/// [product.id] is the temporary client identity.
/// Laravel remains authoritative for the final Product ID.
final class ProductPublishAttempt {
  const ProductPublishAttempt({
    required this.idempotencyKey,
    required this.product,
    required this.status,
    required this.attempts,
    this.lastError,
    this.nextAttemptAt,
  });

  final String idempotencyKey;
  final ProductModel product;
  final ProductPublishAttemptStatus status;
  final int attempts;
  final String? lastError;
  final DateTime? nextAttemptAt;
}

/// Explicit online Product publishing contract.
///
/// Keeping this separate from ProductsCreateDataSource prevents the legacy
/// local create/outbox flow from being mistaken for online publishing.
abstract interface class ProductsIdempotentCreateDataSource {
  Future<ProductModel> createProductIdempotently(
    ProductModel product, {
    required String idempotencyKey,
  });
}

/// Durable local store for online Product publication attempts.
abstract interface class ProductsPublishAttemptDataSource {
  Future<ProductPublishAttempt> preparePublishAttempt({
    required ProductModel product,
    required String idempotencyKey,
  });

  Future<List<ProductPublishAttempt>> getRetryablePublishAttempts();

  Future<void> markPublishAttemptRetry({
    required String idempotencyKey,
    required int attempts,
    required Object error,
    required DateTime nextAttemptAt,
  });

  Future<void> markPublishAttemptPermanentFailure({
    required String idempotencyKey,
    required int attempts,
    required Object error,
  });

  Future<void> completePublishAttempt(String idempotencyKey);
}

/// Local update/delete contract retained for the existing supplier-management
/// flow.
///
/// Create remains part of this interface through ProductsCreateDataSource so
/// existing local implementations stay backward compatible.
abstract interface class ProductsWritableDataSource
    implements ProductsCreateDataSource {
  Future<ProductModel> updateProduct(ProductModel product);

  Future<void> deleteProduct(String productId);
}

/// Stores a product that has already been persisted by Laravel.
///
/// This operation must not create an Outbox operation because the server
/// has already accepted the product and returned its canonical identity.
abstract interface class ProductsSyncedStoreDataSource {
  Future<ProductModel> upsertSyncedProduct(ProductModel product);
}

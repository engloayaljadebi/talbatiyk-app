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

/// Local business-write contract for supplier product management.
///
/// These operations are intentionally separate from discovery caching because
/// create/update/delete may create Outbox operations for later synchronization.
abstract interface class ProductsWritableDataSource {
  Future<ProductModel> createProduct(ProductModel product);

  Future<ProductModel> updateProduct(ProductModel product);

  Future<void> deleteProduct(String productId);
}

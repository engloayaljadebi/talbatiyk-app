import '../models/products_model.dart';
import 'products_datasource.dart';

/// Coordinates customer Product Discovery between the server and Drift.
///
/// Flow on success:
/// Remote -> replace local server snapshot -> read local snapshot.
///
/// Flow on remote failure:
/// Return the existing local snapshot when available. If no cache exists,
/// preserve the original remote error so Presentation can show Retry.
final class ProductsOfflineFirstDataSource implements ProductsDataSource {
  const ProductsOfflineFirstDataSource({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  final ProductsCacheDataSource localDataSource;
  final ProductsDataSource remoteDataSource;

  @override
  Future<List<ProductModel>> getProducts() async {
    late final List<ProductModel> remoteProducts;

    try {
      remoteProducts = await remoteDataSource.getProducts();
    } catch (error, stackTrace) {
      final cachedProducts = await localDataSource.getCachedProducts();

      if (cachedProducts.isNotEmpty) {
        return cachedProducts;
      }

      Error.throwWithStackTrace(error, stackTrace);
    }

    // A successful server response is authoritative even when it is empty.
    // Persist it first so Drift remains the local source of truth.
    await localDataSource.replaceCachedProducts(remoteProducts);

    return localDataSource.getCachedProducts();
  }
}

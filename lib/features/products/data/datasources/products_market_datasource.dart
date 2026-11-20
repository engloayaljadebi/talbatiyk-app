import '../../../auth/domain/services/account_session_fence.dart';
import '../models/products_model.dart';
import 'products_datasource.dart';

/// Market visibility must be confirmed by the server for each refresh.
final class ProductsMarketDataSource implements ProductsDataSource {
  const ProductsMarketDataSource(this.remote, this.sessionFence);

  final ProductsDataSource remote;
  final AccountSessionFence sessionFence;

  @override
  Future<List<ProductModel>> getProducts() async {
    final lease = sessionFence.capture();
    final products = await remote.getProducts();
    lease.ensureCurrent();

    return products;
  }
}

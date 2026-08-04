import '../models/products_model.dart';

/// Contract shared by local, remote, and test product data sources.
abstract interface class ProductsDataSource {
  Future<List<ProductModel>> getProducts();
}

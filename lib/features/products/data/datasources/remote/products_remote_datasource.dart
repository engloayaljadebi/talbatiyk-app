abstract class ProductsRemoteDatasource {
  Future<List<dynamic>> getProductss();
}

class ProductsRemoteDatasourceImpl implements ProductsRemoteDatasource {
  @override
  Future<List<dynamic>> getProductss() async {
    return [];
  }
}

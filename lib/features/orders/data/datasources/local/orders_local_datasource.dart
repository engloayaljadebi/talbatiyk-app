abstract class OrdersLocalDatasource {
  Future<List<dynamic>> getOrderss();
}

class OrdersLocalDatasourceImpl implements OrdersLocalDatasource {
  @override
  Future<List<dynamic>> getOrderss() async {
    return [];
  }
}

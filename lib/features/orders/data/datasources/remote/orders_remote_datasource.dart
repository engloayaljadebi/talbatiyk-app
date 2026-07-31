abstract class OrdersRemoteDatasource {


  Future<List<dynamic>> getOrderss();


}


class OrdersRemoteDatasourceImpl
implements OrdersRemoteDatasource {


  @override
  Future<List<dynamic>> getOrderss() async {

    return [];

  }


}


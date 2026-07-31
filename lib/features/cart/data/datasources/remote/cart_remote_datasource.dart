abstract class CartRemoteDatasource {


  Future<List<dynamic>> getCarts();


}


class CartRemoteDatasourceImpl
implements CartRemoteDatasource {


  @override
  Future<List<dynamic>> getCarts() async {

    return [];

  }


}


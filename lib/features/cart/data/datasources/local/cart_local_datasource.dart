abstract class CartLocalDatasource {


  Future<List<dynamic>> getCarts();


}


class CartLocalDatasourceImpl
implements CartLocalDatasource {


  @override
  Future<List<dynamic>> getCarts() async {

    return [];

  }


}


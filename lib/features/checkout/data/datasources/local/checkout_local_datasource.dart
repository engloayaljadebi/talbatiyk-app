abstract class CheckoutLocalDatasource {


  Future<List<dynamic>> getCheckouts();


}


class CheckoutLocalDatasourceImpl
implements CheckoutLocalDatasource {


  @override
  Future<List<dynamic>> getCheckouts() async {

    return [];

  }


}


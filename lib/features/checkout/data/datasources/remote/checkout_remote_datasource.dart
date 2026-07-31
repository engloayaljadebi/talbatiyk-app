abstract class CheckoutRemoteDatasource {


  Future<List<dynamic>> getCheckouts();


}


class CheckoutRemoteDatasourceImpl
implements CheckoutRemoteDatasource {


  @override
  Future<List<dynamic>> getCheckouts() async {

    return [];

  }


}


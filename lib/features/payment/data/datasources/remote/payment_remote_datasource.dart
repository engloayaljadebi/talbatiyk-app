abstract class PaymentRemoteDatasource {


  Future<List<dynamic>> getPayments();


}


class PaymentRemoteDatasourceImpl
implements PaymentRemoteDatasource {


  @override
  Future<List<dynamic>> getPayments() async {

    return [];

  }


}


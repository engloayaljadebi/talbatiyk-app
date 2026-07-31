abstract class PaymentLocalDatasource {


  Future<List<dynamic>> getPayments();


}


class PaymentLocalDatasourceImpl
implements PaymentLocalDatasource {


  @override
  Future<List<dynamic>> getPayments() async {

    return [];

  }


}


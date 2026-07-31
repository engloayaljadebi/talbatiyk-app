abstract class WalletRemoteDatasource {


  Future<List<dynamic>> getWallets();


}


class WalletRemoteDatasourceImpl
implements WalletRemoteDatasource {


  @override
  Future<List<dynamic>> getWallets() async {

    return [];

  }


}


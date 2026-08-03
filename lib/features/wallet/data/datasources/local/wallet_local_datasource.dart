abstract class WalletLocalDatasource {
  Future<List<dynamic>> getWallets();
}

class WalletLocalDatasourceImpl implements WalletLocalDatasource {
  @override
  Future<List<dynamic>> getWallets() async {
    return [];
  }
}

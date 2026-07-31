abstract class OfflineRemoteDatasource {


  Future<List<dynamic>> getOfflines();


}


class OfflineRemoteDatasourceImpl
implements OfflineRemoteDatasource {


  @override
  Future<List<dynamic>> getOfflines() async {

    return [];

  }


}


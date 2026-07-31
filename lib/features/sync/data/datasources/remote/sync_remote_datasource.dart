abstract class SyncRemoteDatasource {


  Future<List<dynamic>> getSyncs();


}


class SyncRemoteDatasourceImpl
implements SyncRemoteDatasource {


  @override
  Future<List<dynamic>> getSyncs() async {

    return [];

  }


}


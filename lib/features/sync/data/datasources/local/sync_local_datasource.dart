abstract class SyncLocalDatasource {


  Future<List<dynamic>> getSyncs();


}


class SyncLocalDatasourceImpl
implements SyncLocalDatasource {


  @override
  Future<List<dynamic>> getSyncs() async {

    return [];

  }


}


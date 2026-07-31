abstract class BackupRemoteDatasource {


  Future<List<dynamic>> getBackups();


}


class BackupRemoteDatasourceImpl
implements BackupRemoteDatasource {


  @override
  Future<List<dynamic>> getBackups() async {

    return [];

  }


}


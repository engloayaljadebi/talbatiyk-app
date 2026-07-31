abstract class BackupLocalDatasource {


  Future<List<dynamic>> getBackups();


}


class BackupLocalDatasourceImpl
implements BackupLocalDatasource {


  @override
  Future<List<dynamic>> getBackups() async {

    return [];

  }


}


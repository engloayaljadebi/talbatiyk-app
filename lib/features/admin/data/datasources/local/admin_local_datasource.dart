abstract class AdminLocalDatasource {


  Future<List<dynamic>> getAdmins();


}


class AdminLocalDatasourceImpl
implements AdminLocalDatasource {


  @override
  Future<List<dynamic>> getAdmins() async {

    return [];

  }


}


abstract class AdminRemoteDatasource {


  Future<List<dynamic>> getAdmins();


}


class AdminRemoteDatasourceImpl
implements AdminRemoteDatasource {


  @override
  Future<List<dynamic>> getAdmins() async {

    return [];

  }


}


abstract class AuthLocalDatasource {


  Future<List<dynamic>> getAuths();


}


class AuthLocalDatasourceImpl
implements AuthLocalDatasource {


  @override
  Future<List<dynamic>> getAuths() async {

    return [];

  }


}


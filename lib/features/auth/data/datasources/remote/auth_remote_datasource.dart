abstract class AuthRemoteDatasource {


  Future<List<dynamic>> getAuths();


}


class AuthRemoteDatasourceImpl
implements AuthRemoteDatasource {


  @override
  Future<List<dynamic>> getAuths() async {

    return [];

  }


}


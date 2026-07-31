abstract class HomeRemoteDatasource {


  Future<List<dynamic>> getHomes();


}


class HomeRemoteDatasourceImpl
implements HomeRemoteDatasource {


  @override
  Future<List<dynamic>> getHomes() async {

    return [];

  }


}


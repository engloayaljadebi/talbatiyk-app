abstract class SearchRemoteDatasource {


  Future<List<dynamic>> getSearchs();


}


class SearchRemoteDatasourceImpl
implements SearchRemoteDatasource {


  @override
  Future<List<dynamic>> getSearchs() async {

    return [];

  }


}


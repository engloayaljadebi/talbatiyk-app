abstract class FavoritesRemoteDatasource {


  Future<List<dynamic>> getFavoritess();


}


class FavoritesRemoteDatasourceImpl
implements FavoritesRemoteDatasource {


  @override
  Future<List<dynamic>> getFavoritess() async {

    return [];

  }


}


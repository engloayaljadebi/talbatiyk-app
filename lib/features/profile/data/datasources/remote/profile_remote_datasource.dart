abstract class ProfileRemoteDatasource {


  Future<List<dynamic>> getProfiles();


}


class ProfileRemoteDatasourceImpl
implements ProfileRemoteDatasource {


  @override
  Future<List<dynamic>> getProfiles() async {

    return [];

  }


}


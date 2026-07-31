abstract class ProfileLocalDatasource {


  Future<List<dynamic>> getProfiles();


}


class ProfileLocalDatasourceImpl
implements ProfileLocalDatasource {


  @override
  Future<List<dynamic>> getProfiles() async {

    return [];

  }


}


abstract class OfflineLocalDatasource {


  Future<List<dynamic>> getOfflines();


}


class OfflineLocalDatasourceImpl
implements OfflineLocalDatasource {


  @override
  Future<List<dynamic>> getOfflines() async {

    return [];

  }


}


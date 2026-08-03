abstract class HomeLocalDatasource {
  Future<List<dynamic>> getHomes();
}

class HomeLocalDatasourceImpl implements HomeLocalDatasource {
  @override
  Future<List<dynamic>> getHomes() async {
    return [];
  }
}

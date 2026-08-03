abstract class UsersLocalDatasource {
  Future<List<dynamic>> getUserss();
}

class UsersLocalDatasourceImpl implements UsersLocalDatasource {
  @override
  Future<List<dynamic>> getUserss() async {
    return [];
  }
}

abstract class ChatLocalDatasource {


  Future<List<dynamic>> getChats();


}


class ChatLocalDatasourceImpl
implements ChatLocalDatasource {


  @override
  Future<List<dynamic>> getChats() async {

    return [];

  }


}


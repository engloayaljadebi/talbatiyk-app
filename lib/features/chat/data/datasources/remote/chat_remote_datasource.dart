abstract class ChatRemoteDatasource {


  Future<List<dynamic>> getChats();


}


class ChatRemoteDatasourceImpl
implements ChatRemoteDatasource {


  @override
  Future<List<dynamic>> getChats() async {

    return [];

  }


}


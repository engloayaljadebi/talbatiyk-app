abstract class VoiceLocalDatasource {


  Future<List<dynamic>> getVoices();


}


class VoiceLocalDatasourceImpl
implements VoiceLocalDatasource {


  @override
  Future<List<dynamic>> getVoices() async {

    return [];

  }


}


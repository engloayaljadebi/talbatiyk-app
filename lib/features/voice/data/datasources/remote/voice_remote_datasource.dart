abstract class VoiceRemoteDatasource {
  Future<List<dynamic>> getVoices();
}

class VoiceRemoteDatasourceImpl implements VoiceRemoteDatasource {
  @override
  Future<List<dynamic>> getVoices() async {
    return [];
  }
}

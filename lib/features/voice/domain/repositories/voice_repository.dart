import '../entities/voice_entity.dart';

abstract class VoiceRepository {
  Future<List<VoiceEntity>> getVoice();
}

import '../../domain/entities/voice_entity.dart';
import '../../domain/repositories/voice_repository.dart';

class VoiceRepositoryImpl implements VoiceRepository {
  @override
  Future<List<VoiceEntity>> getVoice() async {
    return [];
  }
}

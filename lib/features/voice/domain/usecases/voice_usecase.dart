import '../entities/voice_entity.dart';
import '../repositories/voice_repository.dart';

class VoiceUseCase {
  final VoiceRepository repository;

  VoiceUseCase(this.repository);

  Future<List<VoiceEntity>> call() {
    return repository.getVoice();
  }
}

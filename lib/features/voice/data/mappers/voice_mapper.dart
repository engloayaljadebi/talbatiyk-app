import '../../domain/entities/voice_entity.dart';
import '../models/voice_model.dart';

class VoiceMapper {
  static VoiceEntity toEntity(VoiceModel model) {
    return VoiceEntity(id: model.id);
  }
}

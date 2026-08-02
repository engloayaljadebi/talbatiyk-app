import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/voice_controller.dart';

final voiceProvider = Provider<VoiceController>((ref) {
  return VoiceController();
});

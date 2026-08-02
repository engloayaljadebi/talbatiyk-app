class VoiceModel {
  final String id;

  VoiceModel({required this.id});

  factory VoiceModel.fromJson(Map<String, dynamic> json) {
    return VoiceModel(id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

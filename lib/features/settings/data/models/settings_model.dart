class SettingsModel {

  final String id;

  SettingsModel({
    required this.id,
  });


  factory SettingsModel.fromJson(
      Map<String,dynamic> json
  ){

    return SettingsModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


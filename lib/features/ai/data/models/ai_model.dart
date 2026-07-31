class AiModel {

  final String id;

  AiModel({
    required this.id,
  });


  factory AiModel.fromJson(
      Map<String,dynamic> json
  ){

    return AiModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


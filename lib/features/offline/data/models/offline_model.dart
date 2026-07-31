class OfflineModel {

  final String id;

  OfflineModel({
    required this.id,
  });


  factory OfflineModel.fromJson(
      Map<String,dynamic> json
  ){

    return OfflineModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


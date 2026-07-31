class MapsModel {

  final String id;

  MapsModel({
    required this.id,
  });


  factory MapsModel.fromJson(
      Map<String,dynamic> json
  ){

    return MapsModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


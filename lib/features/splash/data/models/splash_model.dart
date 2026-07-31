class SplashModel {

  final String id;

  SplashModel({
    required this.id,
  });


  factory SplashModel.fromJson(
      Map<String,dynamic> json
  ){

    return SplashModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


class AuthModel {

  final String id;

  AuthModel({
    required this.id,
  });


  factory AuthModel.fromJson(
      Map<String,dynamic> json
  ){

    return AuthModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


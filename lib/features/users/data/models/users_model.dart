class UsersModel {

  final String id;

  UsersModel({
    required this.id,
  });


  factory UsersModel.fromJson(
      Map<String,dynamic> json
  ){

    return UsersModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


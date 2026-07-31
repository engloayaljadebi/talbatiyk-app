class ProfileModel {

  final String id;

  ProfileModel({
    required this.id,
  });


  factory ProfileModel.fromJson(
      Map<String,dynamic> json
  ){

    return ProfileModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


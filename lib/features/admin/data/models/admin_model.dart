class AdminModel {

  final String id;

  AdminModel({
    required this.id,
  });


  factory AdminModel.fromJson(
      Map<String,dynamic> json
  ){

    return AdminModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


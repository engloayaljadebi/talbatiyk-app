class CategoriesModel {

  final String id;

  CategoriesModel({
    required this.id,
  });


  factory CategoriesModel.fromJson(
      Map<String,dynamic> json
  ){

    return CategoriesModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


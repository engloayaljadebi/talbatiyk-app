class FavoritesModel {

  final String id;

  FavoritesModel({
    required this.id,
  });


  factory FavoritesModel.fromJson(
      Map<String,dynamic> json
  ){

    return FavoritesModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


class SearchModel {

  final String id;

  SearchModel({
    required this.id,
  });


  factory SearchModel.fromJson(
      Map<String,dynamic> json
  ){

    return SearchModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


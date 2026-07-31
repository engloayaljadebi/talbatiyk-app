class ReportsModel {

  final String id;

  ReportsModel({
    required this.id,
  });


  factory ReportsModel.fromJson(
      Map<String,dynamic> json
  ){

    return ReportsModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


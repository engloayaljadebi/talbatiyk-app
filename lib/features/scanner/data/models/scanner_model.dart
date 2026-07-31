class ScannerModel {

  final String id;

  ScannerModel({
    required this.id,
  });


  factory ScannerModel.fromJson(
      Map<String,dynamic> json
  ){

    return ScannerModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


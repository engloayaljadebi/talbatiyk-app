class SyncModel {

  final String id;

  SyncModel({
    required this.id,
  });


  factory SyncModel.fromJson(
      Map<String,dynamic> json
  ){

    return SyncModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


class BackupModel {

  final String id;

  BackupModel({
    required this.id,
  });


  factory BackupModel.fromJson(
      Map<String,dynamic> json
  ){

    return BackupModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


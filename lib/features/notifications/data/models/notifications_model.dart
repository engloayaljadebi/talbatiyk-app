class NotificationsModel {

  final String id;

  NotificationsModel({
    required this.id,
  });


  factory NotificationsModel.fromJson(
      Map<String,dynamic> json
  ){

    return NotificationsModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


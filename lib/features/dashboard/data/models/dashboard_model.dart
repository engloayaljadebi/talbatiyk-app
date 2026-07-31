class DashboardModel {

  final String id;

  DashboardModel({
    required this.id,
  });


  factory DashboardModel.fromJson(
      Map<String,dynamic> json
  ){

    return DashboardModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


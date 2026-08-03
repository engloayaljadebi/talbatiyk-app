class HomeModel {
  final String id;

  HomeModel({required this.id});

  factory HomeModel.fromJson(Map<String, dynamic> json) {
    return HomeModel(id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

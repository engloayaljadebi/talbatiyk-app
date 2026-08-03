class OrdersModel {
  final String id;

  OrdersModel({required this.id});

  factory OrdersModel.fromJson(Map<String, dynamic> json) {
    return OrdersModel(id: json['id'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'id': id};
  }
}

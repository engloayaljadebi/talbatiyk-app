class CartModel {

  final String id;

  CartModel({
    required this.id,
  });


  factory CartModel.fromJson(
      Map<String,dynamic> json
  ){

    return CartModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


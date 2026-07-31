class CheckoutModel {

  final String id;

  CheckoutModel({
    required this.id,
  });


  factory CheckoutModel.fromJson(
      Map<String,dynamic> json
  ){

    return CheckoutModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


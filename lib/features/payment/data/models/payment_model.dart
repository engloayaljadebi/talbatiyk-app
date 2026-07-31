class PaymentModel {

  final String id;

  PaymentModel({
    required this.id,
  });


  factory PaymentModel.fromJson(
      Map<String,dynamic> json
  ){

    return PaymentModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


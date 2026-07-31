class WalletModel {

  final String id;

  WalletModel({
    required this.id,
  });


  factory WalletModel.fromJson(
      Map<String,dynamic> json
  ){

    return WalletModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


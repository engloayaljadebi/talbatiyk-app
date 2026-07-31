class ChatModel {

  final String id;

  ChatModel({
    required this.id,
  });


  factory ChatModel.fromJson(
      Map<String,dynamic> json
  ){

    return ChatModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


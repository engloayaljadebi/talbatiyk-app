class OnboardingModel {

  final String id;

  OnboardingModel({
    required this.id,
  });


  factory OnboardingModel.fromJson(
      Map<String,dynamic> json
  ){

    return OnboardingModel(
      id: json['id'] ?? '',
    );

  }


  Map<String,dynamic> toJson(){

    return {
      'id': id,
    };

  }

}


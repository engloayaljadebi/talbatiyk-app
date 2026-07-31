class OnboardingMapper {


 static OnboardingEntity toEntity(
 OnboardingModel model
 ){

   return OnboardingEntity(
     id:model.id,
   );

 }


}


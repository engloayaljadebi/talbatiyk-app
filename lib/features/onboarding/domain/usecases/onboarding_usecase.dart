class OnboardingUseCase {


 final OnboardingRepository repository;


 OnboardingUseCase(
 this.repository
 );


 Future<List<OnboardingEntity>> call(){


 return repository.getOnboardings();


 }


}


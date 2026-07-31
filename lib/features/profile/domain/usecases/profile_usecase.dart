class ProfileUseCase {


 final ProfileRepository repository;


 ProfileUseCase(
 this.repository
 );


 Future<List<ProfileEntity>> call(){


 return repository.getProfiles();


 }


}


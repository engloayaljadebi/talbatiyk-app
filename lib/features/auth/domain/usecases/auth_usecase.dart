class AuthUseCase {


 final AuthRepository repository;


 AuthUseCase(
 this.repository
 );


 Future<List<AuthEntity>> call(){


 return repository.getAuths();


 }


}


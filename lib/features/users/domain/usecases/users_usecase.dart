class UsersUseCase {


 final UsersRepository repository;


 UsersUseCase(
 this.repository
 );


 Future<List<UsersEntity>> call(){


 return repository.getUserss();


 }


}


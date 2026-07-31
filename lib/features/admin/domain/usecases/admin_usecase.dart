class AdminUseCase {


 final AdminRepository repository;


 AdminUseCase(
 this.repository
 );


 Future<List<AdminEntity>> call(){


 return repository.getAdmins();


 }


}


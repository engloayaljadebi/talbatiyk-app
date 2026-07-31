class OfflineUseCase {


 final OfflineRepository repository;


 OfflineUseCase(
 this.repository
 );


 Future<List<OfflineEntity>> call(){


 return repository.getOfflines();


 }


}


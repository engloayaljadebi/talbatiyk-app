class SyncUseCase {


 final SyncRepository repository;


 SyncUseCase(
 this.repository
 );


 Future<List<SyncEntity>> call(){


 return repository.getSyncs();


 }


}


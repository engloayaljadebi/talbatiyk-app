class MapsUseCase {


 final MapsRepository repository;


 MapsUseCase(
 this.repository
 );


 Future<List<MapsEntity>> call(){


 return repository.getMapss();


 }


}


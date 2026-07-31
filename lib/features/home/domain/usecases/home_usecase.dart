class HomeUseCase {


 final HomeRepository repository;


 HomeUseCase(
 this.repository
 );


 Future<List<HomeEntity>> call(){


 return repository.getHomes();


 }


}


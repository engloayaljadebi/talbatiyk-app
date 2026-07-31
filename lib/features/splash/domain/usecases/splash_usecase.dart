class SplashUseCase {


 final SplashRepository repository;


 SplashUseCase(
 this.repository
 );


 Future<List<SplashEntity>> call(){


 return repository.getSplashs();


 }


}


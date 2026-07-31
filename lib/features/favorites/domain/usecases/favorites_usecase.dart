class FavoritesUseCase {


 final FavoritesRepository repository;


 FavoritesUseCase(
 this.repository
 );


 Future<List<FavoritesEntity>> call(){


 return repository.getFavoritess();


 }


}


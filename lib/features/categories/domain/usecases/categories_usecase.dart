class CategoriesUseCase {


 final CategoriesRepository repository;


 CategoriesUseCase(
 this.repository
 );


 Future<List<CategoriesEntity>> call(){


 return repository.getCategoriess();


 }


}


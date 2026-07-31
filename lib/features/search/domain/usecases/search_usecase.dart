class SearchUseCase {


 final SearchRepository repository;


 SearchUseCase(
 this.repository
 );


 Future<List<SearchEntity>> call(){


 return repository.getSearchs();


 }


}


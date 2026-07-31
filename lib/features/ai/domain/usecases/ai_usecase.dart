class AiUseCase {


 final AiRepository repository;


 AiUseCase(
 this.repository
 );


 Future<List<AiEntity>> call(){


 return repository.getAis();


 }


}


class CheckoutUseCase {


 final CheckoutRepository repository;


 CheckoutUseCase(
 this.repository
 );


 Future<List<CheckoutEntity>> call(){


 return repository.getCheckouts();


 }


}


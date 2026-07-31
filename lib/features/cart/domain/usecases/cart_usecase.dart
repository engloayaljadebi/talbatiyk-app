class CartUseCase {


 final CartRepository repository;


 CartUseCase(
 this.repository
 );


 Future<List<CartEntity>> call(){


 return repository.getCarts();


 }


}


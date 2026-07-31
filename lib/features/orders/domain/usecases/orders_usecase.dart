class OrdersUseCase {


 final OrdersRepository repository;


 OrdersUseCase(
 this.repository
 );


 Future<List<OrdersEntity>> call(){


 return repository.getOrderss();


 }


}


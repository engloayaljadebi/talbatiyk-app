class PaymentUseCase {


 final PaymentRepository repository;


 PaymentUseCase(
 this.repository
 );


 Future<List<PaymentEntity>> call(){


 return repository.getPayments();


 }


}


class WalletUseCase {


 final WalletRepository repository;


 WalletUseCase(
 this.repository
 );


 Future<List<WalletEntity>> call(){


 return repository.getWallets();


 }


}


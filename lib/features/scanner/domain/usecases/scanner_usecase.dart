class ScannerUseCase {


 final ScannerRepository repository;


 ScannerUseCase(
 this.repository
 );


 Future<List<ScannerEntity>> call(){


 return repository.getScanners();


 }


}


class BackupUseCase {


 final BackupRepository repository;


 BackupUseCase(
 this.repository
 );


 Future<List<BackupEntity>> call(){


 return repository.getBackups();


 }


}


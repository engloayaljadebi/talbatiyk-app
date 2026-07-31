class ReportsUseCase {


 final ReportsRepository repository;


 ReportsUseCase(
 this.repository
 );


 Future<List<ReportsEntity>> call(){


 return repository.getReportss();


 }


}


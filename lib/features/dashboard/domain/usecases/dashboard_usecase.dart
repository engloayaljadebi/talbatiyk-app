class DashboardUseCase {


 final DashboardRepository repository;


 DashboardUseCase(
 this.repository
 );


 Future<List<DashboardEntity>> call(){


 return repository.getDashboards();


 }


}


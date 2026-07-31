class CameraUseCase {


 final CameraRepository repository;


 CameraUseCase(
 this.repository
 );


 Future<List<CameraEntity>> call(){


 return repository.getCameras();


 }


}


import '../entities/home_entity.dart';
import '../repositories/home_repository.dart';

class HomeUseCase {
  final HomeRepository repository;

  HomeUseCase(this.repository);

  Future<List<HomeEntity>> call() {
    return repository.getHome();
  }
}

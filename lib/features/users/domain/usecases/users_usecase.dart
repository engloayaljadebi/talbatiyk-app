import '../entities/users_entity.dart';
import '../repositories/users_repository.dart';

class UsersUseCase {
  final UsersRepository repository;

  UsersUseCase(this.repository);

  Future<List<UsersEntity>> call() {
    return repository.getUsers();
  }
}

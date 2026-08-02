import '../../domain/entities/users_entity.dart';
import '../../domain/repositories/users_repository.dart';

class UsersRepositoryImpl implements UsersRepository {
  @override
  Future<List<UsersEntity>> getUsers() async {
    return [];
  }
}

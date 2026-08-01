import '../entities/users_entity.dart';

abstract class UsersRepository {
  Future<List<UsersEntity>> getUsers();
}

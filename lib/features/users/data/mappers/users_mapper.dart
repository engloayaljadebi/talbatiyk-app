import '../../domain/entities/users_entity.dart';
import '../models/users_model.dart';

class UsersMapper {
  static UsersEntity toEntity(UsersModel model) {
    return UsersEntity(id: model.id);
  }
}

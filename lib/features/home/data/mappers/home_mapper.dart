import '../../domain/entities/home_entity.dart';
import '../models/home_model.dart';

class HomeMapper {
  static HomeEntity toEntity(HomeModel model) {
    return HomeEntity(id: model.id);
  }
}

import '../../domain/entities/wallet_entity.dart';
import '../models/wallet_model.dart';

class WalletMapper {
  static WalletEntity toEntity(WalletModel model) {
    return WalletEntity(id: model.id);
  }
}

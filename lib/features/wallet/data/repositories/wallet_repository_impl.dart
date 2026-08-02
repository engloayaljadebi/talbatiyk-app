import '../../domain/entities/wallet_entity.dart';
import '../../domain/repositories/wallet_repository.dart';

class WalletRepositoryImpl implements WalletRepository {
  @override
  Future<List<WalletEntity>> getWallet() async {
    return [];
  }
}

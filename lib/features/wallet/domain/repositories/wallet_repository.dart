import '../entities/wallet_entity.dart';

abstract class WalletRepository {
  Future<List<WalletEntity>> getWallets();
}

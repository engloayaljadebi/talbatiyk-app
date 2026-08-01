import '../entities/wallet_entity.dart';
import '../repositories/wallet_repository.dart';

class WalletUseCase {
  final WalletRepository repository;

  WalletUseCase(this.repository);

  Future<List<WalletEntity>> call() {
    return repository.getWallets();
  }
}

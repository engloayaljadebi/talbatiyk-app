import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/wallet_controller.dart';

final walletProvider = Provider<WalletController>((ref) {
  return WalletController();
});

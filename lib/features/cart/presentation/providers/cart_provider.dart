import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../data/datasources/local/cart_local_datasource.dart';
import '../controllers/cart_controller.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  return CartLocalDataSource(ref.watch(appDatabaseProvider));
});

final cartProvider = ChangeNotifierProvider<CartController>((ref) {
  return CartController(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
  );
});

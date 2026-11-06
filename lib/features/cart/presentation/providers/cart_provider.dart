import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/datasources/local/cart_local_datasource.dart';
import '../controllers/cart_controller.dart';

final cartLocalDataSourceProvider = Provider<CartLocalDataSource>((ref) {
  final ownerUserId = ref.watch(
    authProvider.select(
      (auth) => auth.state.isAuthenticated ? auth.state.user?.id : null,
    ),
  );

  return CartLocalDataSource(
    ref.watch(appDatabaseProvider),
    ownerUserId: ownerUserId,
  );
});

final cartProvider = ChangeNotifierProvider<CartController>((ref) {
  return CartController(
    localDataSource: ref.watch(cartLocalDataSourceProvider),
  );
});
// Loads carts belonging to the currently authenticated account.
final cartListProvider = FutureProvider<List<({String id, String name})>>((
  ref,
) async {
  final dataSource = ref.watch(cartLocalDataSourceProvider);
  return dataSource.listCarts();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talbatiyk/features/cart/presentation/controllers/cart_controller.dart';

final cartProvider = ChangeNotifierProvider<CartController>((ref) {
  return CartController();
});

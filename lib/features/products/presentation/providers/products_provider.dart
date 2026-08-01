import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/products_controller.dart';

final productsProvider = ChangeNotifierProvider<ProductsController>((ref) {
  return ProductsController();
});

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/orders_controller.dart';

final ordersProvider = Provider<OrdersController>((ref) {
  return OrdersController();
});

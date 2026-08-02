import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/home_controller.dart';

final homeProvider = Provider<HomeController>((ref) {
  return HomeController();
});

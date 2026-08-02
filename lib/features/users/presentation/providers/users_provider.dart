import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/users_controller.dart';

final usersProvider = Provider<UsersController>((ref) {
  return UsersController();
});

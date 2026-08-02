import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/notifications_controller.dart';

final notificationsProvider = Provider<NotificationsController>((ref) {
  return NotificationsController();
});

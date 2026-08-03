abstract class NotificationsLocalDatasource {
  Future<List<dynamic>> getNotificationss();
}

class NotificationsLocalDatasourceImpl implements NotificationsLocalDatasource {
  @override
  Future<List<dynamic>> getNotificationss() async {
    return [];
  }
}

abstract class NotificationsRemoteDatasource {
  Future<List<dynamic>> getNotificationss();
}

class NotificationsRemoteDatasourceImpl
    implements NotificationsRemoteDatasource {
  @override
  Future<List<dynamic>> getNotificationss() async {
    return [];
  }
}

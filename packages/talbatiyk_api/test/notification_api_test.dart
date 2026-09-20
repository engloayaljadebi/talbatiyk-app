import 'package:test/test.dart';
import 'package:talbatiyk_api/talbatiyk_api.dart';


/// tests for NotificationApi
void main() {
  final instance = TalbatiykApi().getNotificationApi();

  group(NotificationApi, () {
    //Future<NotificationIndex200Response> notificationIndex({ int page, int perPage }) async
    test('test notificationIndex', () async {
      // TODO
    });

    //Future<NotificationMarkAllRead200Response> notificationMarkAllRead() async
    test('test notificationMarkAllRead', () async {
      // TODO
    });

    // Mark one notification owned by the authenticated user as read
    //
    //Future<NotificationMarkRead200Response> notificationMarkRead(String notification) async
    test('test notificationMarkRead', () async {
      // TODO
    });

    //Future<NotificationUnreadCount200Response> notificationUnreadCount() async
    test('test notificationUnreadCount', () async {
      // TODO
    });

  });
}

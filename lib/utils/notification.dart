import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class Notification {
  static final _notificatons = FlutterLocalNotificationsPlugin();

  static Future _notificationDetials() async {
    return NotificationDetails(
        android: AndroidNotificationDetails('channel id', 'channel name',
            importance: Importance.max),
        iOS: IOSNotificationDetails());
  }

  static Future showNotification({
    int? id,
    String? title,
    String? body,
    String? payload,
  }) async {
    _notificatons.show(id!, title, body, await _notificationDetials(),
        payload: payload);
  }
}

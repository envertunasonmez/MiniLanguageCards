import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> scheduleDailyNotification() async {
    await _notificationsPlugin.zonedSchedule(
      0,
      'Dil Kartları',
      'Bugünün 5 kelimesi hazır!',
      _nextInstanceOfNineAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_channel',
          'Günlük Bildirim',
          channelDescription: 'Her gün yeni kelime bildirimi',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexact, // ⚡ zorunlu
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  static tz.TZDateTime _nextInstanceOfNineAM() {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 9);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

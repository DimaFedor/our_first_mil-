import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart';
import 'package:timezone/timezone.dart';

class ReminderService {
  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();
  bool initialized = false;
  Future<bool> configure(bool enabled, String title, String body) async {
    if (kIsWeb) return false;
    if (!initialized) {
      initializeTimeZones();
      final deviceZone = await FlutterTimezone.getLocalTimezone();
      setLocalLocation(getLocation(deviceZone.identifier));
      await plugin.initialize(
        const InitializationSettings(
          android: AndroidInitializationSettings('ic_notification'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      initialized = true;
    }
    await plugin.cancel(19);
    if (!enabled) return true;
    final androidGranted = await plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    final iosGranted = await plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: false, sound: true);
    if (androidGranted == false || iosGranted == false) return false;
    final now = TZDateTime.now(local);
    var next = TZDateTime(local, now.year, now.month, now.day, 19);
    if (!next.isAfter(now)) {
      next = TZDateTime(local, now.year, now.month, now.day + 1, 19);
    }
    await plugin.zonedSchedule(
      19,
      title,
      body,
      next,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'learning_reminders',
          'Learning reminders',
          channelDescription: 'Daily learning reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    return true;
  }
}

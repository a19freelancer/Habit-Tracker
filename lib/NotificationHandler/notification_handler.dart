import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/intl.dart';

final FlutterLocalNotificationsPlugin _notificationsPlugin =
    FlutterLocalNotificationsPlugin();

// Get Pakistan time zone location once
final tz.Location _pakistanTimeZone = tz.getLocation('Asia/Karachi');

Future<void> scheduleHabitForPlannedDays(
    int habitId, String habitName, String plannedDays) async {
  tz.initializeTimeZones();

  final daysList = plannedDays.split(',').where((d) => d.isNotEmpty);

  for (String dayString in daysList) {
    try {
      // Split date string into components
      final dateParts = dayString.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);

      // Create 9 AM in Pakistan time
      final scheduledTime = tz.TZDateTime(
        _pakistanTimeZone,
        year,
        month,
        day,
        9, // 9 AM
        0,
      );

      // Check if time is in the past
      if (scheduledTime.isBefore(tz.TZDateTime.now(_pakistanTimeZone))) {
        print("⏰ Skipping past date: $dayString");
        continue;
      }

      await _notificationsPlugin.zonedSchedule(
        habitId + scheduledTime.millisecondsSinceEpoch,
        'Habit Reminder',
        'Don\'t forget to complete "$habitName" today!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'habit_reminders',
            'Habit Reminders',
            channelDescription: 'Daily habit reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Remove matchDateTimeComponents for single notifications
        payload: habitId.toString(),
      );

      print(
          "✅ Scheduled notification for $habitName on $dayString at 9 AM PKT");
    } catch (e) {
      print("❌ Error scheduling notification for $habitName: $e");
    }
  }
}

Future<void> scheduleTestNotification() async {
  tz.initializeTimeZones();

  final now = tz.TZDateTime.now(_pakistanTimeZone);
  // Schedule for 2 minutes from now for testing
  final scheduledTime = now.add(const Duration(minutes: 2));

  print("⏰ Scheduling test notification for: $scheduledTime (PKT)");

  await _notificationsPlugin.zonedSchedule(
    1001,
    'Test Reminder',
    'This is a test notification scheduled in Pakistan Time!',
    scheduledTime,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Manual test notification',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );

  print("✅ Test notification scheduled successfully!");
}

Future<void> initializeNotifications() async {
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      _notificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  bool? granted = await androidImplementation?.requestNotificationsPermission();
  if (granted == null || !granted) {
    print("❌ Notification permission denied!");
    return;
  }
  print("✅ Notification permission granted!");
}

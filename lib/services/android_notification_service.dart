import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_schedule_item.dart';
import 'notification_service.dart';

class AndroidNotificationService implements NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _channel =
      AndroidNotificationChannel(
    'calendar_notifications',
    'Calendar Notifications',
    description: 'Notifications for reminders and alarms',
    importance: Importance.max,
  );

  @override
  Future<void> initialize() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidInit);

    await _plugin.initialize(settings: settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(_channel);
  }

  @override
  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    final notificationGranted =
        await android?.requestNotificationsPermission() ?? false;

    await android?.requestExactAlarmsPermission();

    return notificationGranted;
  }

  @override
  Future<void> syncSchedules(List<NotificationScheduleItem> items) async {
    await cancelAll();

    for (final item in items) {
      final scheduled = tz.TZDateTime.from(item.scheduledAt, tz.local);

      if (!scheduled.isAfter(tz.TZDateTime.now(tz.local))) {
        continue;
      }

      await _plugin.zonedSchedule(
        id: item.entryId.hashCode,
        title: item.title,
        body: item.body.isEmpty ? 'Scheduled reminder' : item.body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'calendar_notifications',
            'Calendar Notifications',
            channelDescription: 'Notifications for reminders and alarms',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelByEntryId(String entryId) async {
    await _plugin.cancel(id: entryId.hashCode);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

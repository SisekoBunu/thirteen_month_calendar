import 'dart:async';
import 'dart:html' as html;

import '../models/notification_schedule_item.dart';
import 'notification_service.dart';

class WebNotificationService implements NotificationService {
  final Map<String, Timer> _timers = {};

  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async {
    if (!html.Notification.supported) {
      return false;
    }

    if (html.Notification.permission == 'granted') {
      return true;
    }

    final permission = await html.Notification.requestPermission();
    return permission == 'granted';
  }

  @override
  Future<void> syncSchedules(List<NotificationScheduleItem> items) async {
    await cancelAll();

    final allowed = await requestPermission();
    if (!allowed) {
      return;
    }

    final now = DateTime.now();

    for (final item in items) {
      if (!item.scheduledAt.isAfter(now)) {
        continue;
      }

      final delay = item.scheduledAt.difference(now);

      _timers[item.entryId] = Timer(delay, () {
        html.Notification(
          item.title,
          body: item.body.isEmpty ? 'Scheduled reminder' : item.body,
        );
        _timers.remove(item.entryId);
      });
    }
  }

  @override
  Future<void> cancelByEntryId(String entryId) async {
    _timers[entryId]?.cancel();
    _timers.remove(entryId);
  }

  @override
  Future<void> cancelAll() async {
    for (final timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
  }
}

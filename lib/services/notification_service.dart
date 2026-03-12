import '../models/notification_schedule_item.dart';

abstract class NotificationService {
  Future<void> initialize();

  Future<bool> requestPermission();

  Future<void> syncSchedules(List<NotificationScheduleItem> items);

  Future<void> cancelByEntryId(String entryId);

  Future<void> cancelAll();
}

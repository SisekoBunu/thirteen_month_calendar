import '../models/notification_schedule_item.dart';
import 'notification_service.dart';

class NoopNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> syncSchedules(List<NotificationScheduleItem> items) async {}

  @override
  Future<void> cancelByEntryId(String entryId) async {}

  @override
  Future<void> cancelAll() async {}
}

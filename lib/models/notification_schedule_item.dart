import '../models/calendar_entry.dart';

class NotificationScheduleItem {
  final String entryId;
  final String storageKey;
  final CalendarEntryType type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final bool isRecurring;

  const NotificationScheduleItem({
    required this.entryId,
    required this.storageKey,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.isRecurring,
  });
}

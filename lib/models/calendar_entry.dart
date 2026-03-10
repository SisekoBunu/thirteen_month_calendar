enum CalendarEntryType { event, reminder, alarm }

class CalendarEntry {
  final String id;
  final CalendarEntryType type;
  final String title;
  final String details;
  final String timeLabel;

  const CalendarEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.details,
    required this.timeLabel,
  });
}

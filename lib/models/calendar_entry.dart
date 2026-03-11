enum CalendarEntryType { event, reminder, alarm }

enum CalendarEntryRecurrence { none, daily, weekly, monthly, yearly }

class CalendarEntry {
  final String id;
  final CalendarEntryType type;
  final String title;
  final String details;
  final String timeLabel;
  final CalendarEntryRecurrence recurrence;
  final int anchorYear;
  final int anchorMonthIndex;
  final int anchorDay;
  final int? recurrenceEndYear;
  final int? recurrenceEndMonthIndex;
  final int? recurrenceEndDay;
  final List<int> excludedOrdinals;

  const CalendarEntry({
    required this.id,
    required this.type,
    required this.title,
    required this.details,
    required this.timeLabel,
    required this.recurrence,
    required this.anchorYear,
    required this.anchorMonthIndex,
    required this.anchorDay,
    required this.recurrenceEndYear,
    required this.recurrenceEndMonthIndex,
    required this.recurrenceEndDay,
    required this.excludedOrdinals,
  });

  bool get hasRecurrenceEnd =>
      recurrenceEndYear != null &&
      recurrenceEndMonthIndex != null &&
      recurrenceEndDay != null;
}

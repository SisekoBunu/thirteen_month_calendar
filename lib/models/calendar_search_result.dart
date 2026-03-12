import 'calendar_entry.dart';

class CalendarSearchResult {
  final String storageKey;
  final String culture;
  final int year;
  final int monthIndex;
  final int day;
  final CalendarEntry entry;
  final bool isRecurringMatch;

  const CalendarSearchResult({
    required this.storageKey,
    required this.culture,
    required this.year,
    required this.monthIndex,
    required this.day,
    required this.entry,
    required this.isRecurringMatch,
  });
}

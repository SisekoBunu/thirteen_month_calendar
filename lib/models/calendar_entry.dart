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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'details': details,
      'timeLabel': timeLabel,
      'recurrence': recurrence.name,
      'anchorYear': anchorYear,
      'anchorMonthIndex': anchorMonthIndex,
      'anchorDay': anchorDay,
      'recurrenceEndYear': recurrenceEndYear,
      'recurrenceEndMonthIndex': recurrenceEndMonthIndex,
      'recurrenceEndDay': recurrenceEndDay,
      'excludedOrdinals': excludedOrdinals,
    };
  }

  factory CalendarEntry.fromJson(Map<String, dynamic> json) {
    return CalendarEntry(
      id: json['id'] as String? ?? '',
      type: CalendarEntryType.values.firstWhere(
        (value) => value.name == (json['type'] as String? ?? 'event'),
        orElse: () => CalendarEntryType.event,
      ),
      title: json['title'] as String? ?? '',
      details: json['details'] as String? ?? '',
      timeLabel: json['timeLabel'] as String? ?? '',
      recurrence: CalendarEntryRecurrence.values.firstWhere(
        (value) => value.name == (json['recurrence'] as String? ?? 'none'),
        orElse: () => CalendarEntryRecurrence.none,
      ),
      anchorYear: json['anchorYear'] as int? ?? 1,
      anchorMonthIndex: json['anchorMonthIndex'] as int? ?? 0,
      anchorDay: json['anchorDay'] as int? ?? 1,
      recurrenceEndYear: json['recurrenceEndYear'] as int?,
      recurrenceEndMonthIndex: json['recurrenceEndMonthIndex'] as int?,
      recurrenceEndDay: json['recurrenceEndDay'] as int?,
      excludedOrdinals: (json['excludedOrdinals'] as List<dynamic>? ?? [])
          .map((value) => value as int)
          .toList(),
    );
  }
}

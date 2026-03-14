import 'calendar_day.dart';

class CalendarMonthView {
  final String monthName;
  final String yearLabel;
  final List<CalendarDay> days;

  const CalendarMonthView({
    required this.monthName,
    required this.yearLabel,
    required this.days,
  });
}

import '../models/calendar_type.dart';
import 'gregorian_calendar_engine.dart';

class ChristianCalendarEngine extends GregorianCalendarEngine {
  @override
  CalendarType get type => CalendarType.christian;

  @override
  String get displayName => "Christian (Ussher Chronology)";

  int _convertToChristianYear(int gregorianYear) {
    return gregorianYear + 4004;
  }

  @override
  int getDisplayYear() {
    return _convertToChristianYear(selectedGregorianDate.year);
  }

  @override
  String getMonthYearLabel() {
    final gDate = selectedGregorianDate;
    final monthName = getMonthNames()[gDate.month - 1];
    return "$monthName ${getDisplayYear()}";
  }

  @override
  String getFormattedSelectedDate() {
    final gDate = selectedGregorianDate;
    final monthName = getMonthNames()[gDate.month - 1];
    return "${gDate.day} $monthName ${getDisplayYear()}";
  }

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final holidays = <String>[];

    if (monthIndex == 0 && day == 6) {
      holidays.add('Epiphany');
    }
    if (monthIndex == 2 && day == 25) {
      holidays.add('Annunciation');
    }
    if (monthIndex == 11 && day == 25) {
      holidays.add('Christmas');
    }

    return holidays;
  }

  @override
  List<String> getTimelineEventsForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final events = <String>[];

    if (monthIndex == 11 && day == 25) {
      events.add('Birth of Jesus');
    }
    if (monthIndex == 2 && day == 25) {
      events.add('Annunciation to Mary');
    }

    return events;
  }
}

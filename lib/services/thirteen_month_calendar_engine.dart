import '../models/calendar_type.dart';
import 'calendar_engine.dart';
import 'calendar_logic.dart';

class ThirteenMonthCalendarEngine implements CalendarEngine {
  int _year = DateTime.now().year;
  int _monthIndex = 0;
  int _day = 1;

  static const List<String> months = [
    "April",
    "May",
    "June",
    "July",
    "August",
    "Sol",
    "September",
    "October",
    "November",
    "December",
    "January",
    "February",
    "March"
  ];

  @override
  CalendarType get type => CalendarType.thirteenMonth;

  @override
  String get displayName => '13-Month Calendar';

  @override
  DateTime get selectedGregorianDate =>
      CalendarLogic.convertCustomToGregorianDate(_year, _monthIndex, _day);

  @override
  void selectGregorianDate(DateTime date) {
    final custom = CalendarLogic.convertGregorianToCustomDate(date);
    _year = custom.year ?? _year;
    _monthIndex = custom.monthIndex ?? _monthIndex;
    _day = custom.day ?? _day;
  }

  @override
  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    _monthIndex = monthIndex;
    _day = day.clamp(1, 28);
  }

  @override
  void goToNextMonth() {
    _monthIndex++;
    if (_monthIndex >= months.length) {
      _monthIndex = 0;
      _year++;
    }
  }

  @override
  void goToPreviousMonth() {
    _monthIndex--;
    if (_monthIndex < 0) {
      _monthIndex = months.length - 1;
      _year--;
    }
  }

  @override
  List<String> getMonthNames() => months;

  @override
  int getDaysInMonth(int monthIndex, int year) => 28;

  @override
  String getFormattedSelectedDate() {
    return '$_day ${months[_monthIndex]} $_year';
  }

  @override
  String getMonthYearLabel() {
    return '${months[_monthIndex]} $_year';
  }

  @override
  int getDisplayYear() => _year;

  @override
  int getSelectedMonthIndex() => _monthIndex;

  @override
  int getSelectedDay() => _day;

  @override
  int getTodayMonthIndex() {
    final custom = CalendarLogic.convertGregorianToCustomDate(DateTime.now());
    return custom.monthIndex ?? 0;
  }

  @override
  int getTodayDay() {
    final custom = CalendarLogic.convertGregorianToCustomDate(DateTime.now());
    return custom.day ?? 1;
  }

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    return const [];
  }

  @override
  List<String> getTimelineEventsForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    return const [];
  }
}

import '../models/calendar_type.dart';
import 'calendar_engine.dart';

class GregorianCalendarEngine implements CalendarEngine {
  DateTime _selectedDate = DateTime.now();

  @override
  CalendarType get type => CalendarType.gregorian;

  @override
  String get displayName => "Gregorian";

  @override
  DateTime get selectedGregorianDate => _selectedDate;

  @override
  void selectGregorianDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
  }

  @override
  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    final year = _selectedDate.year;
    final maxDay = getDaysInMonth(monthIndex, year);
    final safeDay = day > maxDay ? maxDay : day;
    _selectedDate = DateTime(year, monthIndex + 1, safeDay);
  }

  @override
  void goToNextMonth() {
    int newYear = _selectedDate.year;
    int newMonthIndex = _selectedDate.month;

    if (newMonthIndex > 11) {
      newMonthIndex = 0;
      newYear++;
    }

    final maxDay = getDaysInMonth(newMonthIndex, newYear);
    final safeDay = _selectedDate.day > maxDay ? maxDay : _selectedDate.day;

    _selectedDate = DateTime(newYear, newMonthIndex + 1, safeDay);
  }

  @override
  void goToPreviousMonth() {
    int newYear = _selectedDate.year;
    int newMonthIndex = _selectedDate.month - 2;

    if (newMonthIndex < 0) {
      newMonthIndex = 11;
      newYear--;
    }

    final maxDay = getDaysInMonth(newMonthIndex, newYear);
    final safeDay = _selectedDate.day > maxDay ? maxDay : _selectedDate.day;

    _selectedDate = DateTime(newYear, newMonthIndex + 1, safeDay);
  }

  @override
  String getMonthYearLabel() {
    return "${getMonthNames()[_selectedDate.month - 1]} ${_selectedDate.year}";
  }

  @override
  String getFormattedSelectedDate() {
    return "${_selectedDate.day} ${getMonthNames()[_selectedDate.month - 1]} ${_selectedDate.year}";
  }

  @override
  int getDisplayYear() => _selectedDate.year;

  @override
  int getSelectedMonthIndex() => _selectedDate.month - 1;

  @override
  int getSelectedDay() => _selectedDate.day;

  @override
  int getTodayMonthIndex() => DateTime.now().month - 1;

  @override
  int getTodayDay() => DateTime.now().day;

  static const List<String> _months = [
    "January","February","March","April","May","June",
    "July","August","September","October","November","December"
  ];

  @override
  List<String> getMonthNames() => _months;

  @override
  int getDaysInMonth(int monthIndex, int year) {
    switch (monthIndex) {
      case 0: return 31;
      case 1:
        final isLeap =
            (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
        return isLeap ? 29 : 28;
      case 2: return 31;
      case 3: return 30;
      case 4: return 31;
      case 5: return 30;
      case 6: return 31;
      case 7: return 31;
      case 8: return 30;
      case 9: return 31;
      case 10: return 30;
      case 11: return 31;
      default: return 30;
    }
  }

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final holidays = <String>[];

    if (monthIndex == 0 && day == 1) {
      holidays.add("New Year's Day");
    }
    if (monthIndex == 11 && day == 25) {
      holidays.add("Christmas Day");
    }
    if (monthIndex == 11 && day == 26) {
      holidays.add("Boxing Day");
    }

      final month = monthIndex + 1;

  int nthSunday(int m, int nth) {
    final first = DateTime(year, m, 1);
    final offset = (DateTime.sunday - first.weekday + 7) % 7;
    return 1 + offset + (nth - 1) * 7;
  }

  int lastFriday(int m) {
    final last = DateTime(year, m + 1, 0);
    final offset = (last.weekday - DateTime.friday + 7) % 7;
    return last.day - offset;
  }

  if (month == 2 && day == 14) holidays.add("Valentine's Day");
  if (month == 3 && day == 8) holidays.add("International Women's Day");
  if (month == 4 && day == 22) holidays.add("Earth Day");
  if (month == 5 && day == 1) holidays.add("International Workers' Day");
  if (month == 6 && day == 21) holidays.add("International Day of Yoga");
  if (month == 8 && day == 12) holidays.add("International Youth Day");
  if (month == 9 && day == 21) holidays.add("International Day of Peace");
  if (month == 10 && day == 31) holidays.add("Halloween");
  if (month == 11 && day == 11) holidays.add("Remembrance Day");
  if (month == 11 && day == 20) holidays.add("Universal Children's Day");

  if (month == 5 && day == nthSunday(5, 2)) {
    holidays.add("Mother's Day");
  }

  if (month == 6 && day == nthSunday(6, 3)) {
    holidays.add("Father's Day");
  }

  if (month == 11 && day == lastFriday(11)) {
    holidays.add("Black Friday");
  }

  return holidays;
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


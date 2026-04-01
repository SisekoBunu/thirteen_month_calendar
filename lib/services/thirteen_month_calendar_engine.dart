import '../models/calendar_type.dart';
import 'calendar_engine.dart';

class ThirteenMonthCalendarEngine implements CalendarEngine {
  /// Anchor: 1 April 2026 = Day 1
  static final DateTime _anchorGregorian = DateTime(2026, 4, 1);

  int _year = 2026;
  int _monthIndex = 0;
  int _day = 1;

  static const List<String> months = [
    "April","May","June","July","August","Sol",
    "September","October","November","December",
    "January","February","March"
  ];

  static const int daysPerMonth = 28;
  static const int monthsPerYear = 13;

  @override
  CalendarType get type => CalendarType.thirteenMonth;

  @override
  String get displayName => '13-Month Calendar';

  /// ?? TRUE INTERNAL CLOCK (independent)
  void _syncWithToday() {
    final today = DateTime.now();
    final diffDays = today.difference(_anchorGregorian).inDays;

    final totalDays = diffDays < 0 ? 0 : diffDays;

    final totalMonths = totalDays ~/ daysPerMonth;
    final dayOfMonth = (totalDays % daysPerMonth) + 1;

    final yearOffset = totalMonths ~/ monthsPerYear;
    final month = totalMonths % monthsPerYear;

    _year = 2026 + yearOffset;
    _monthIndex = month;
    _day = dayOfMonth;
  }

  @override
  DateTime get selectedGregorianDate => DateTime.now();

  @override
  void selectGregorianDate(DateTime date) {
    _syncWithToday();
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
    if (_monthIndex >= monthsPerYear) {
      _monthIndex = 0;
      _year++;
    }
  }

  @override
  void goToPreviousMonth() {
    _monthIndex--;
    if (_monthIndex < 0) {
      _monthIndex = monthsPerYear - 1;
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
    _syncWithToday();
    return _monthIndex;
  }

  @override
  int getTodayDay() {
    _syncWithToday();
    return _day;
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

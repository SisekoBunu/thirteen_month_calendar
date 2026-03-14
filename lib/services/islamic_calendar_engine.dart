import 'dart:math' as math;

import '../models/calendar_type.dart';
import 'calendar_engine.dart';

class IslamicCalendarEngine implements CalendarEngine {
  DateTime _selectedDate = DateTime.now();

  @override
  CalendarType get type => CalendarType.islamic;

  @override
  String get displayName => "Islamic (Hijri)";

  @override
  DateTime get selectedGregorianDate => _selectedDate;

  static const List<String> _months = [
    "Muharram",
    "Safar",
    "Rabi al-Awwal",
    "Rabi al-Thani",
    "Jumada al-Awwal",
    "Jumada al-Thani",
    "Rajab",
    "Sha'ban",
    "Ramadan",
    "Shawwal",
    "Dhu al-Qadah",
    "Dhu al-Hijjah"
  ];

  @override
  void selectGregorianDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day);
  }

  @override
  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    final hijri = _gregorianToHijri(_selectedDate);
    final year = hijri.year;
    final maxDay = getDaysInMonth(monthIndex, year);
    final safeDay = day > maxDay ? maxDay : day;
    _selectedDate = _hijriToGregorian(year, monthIndex, safeDay);
  }

  @override
  void goToNextMonth() {
    final hijri = _gregorianToHijri(_selectedDate);

    int monthIndex = hijri.monthIndex + 1;
    int year = hijri.year;

    if (monthIndex >= 12) {
      monthIndex = 0;
      year++;
    }

    final maxDay = getDaysInMonth(monthIndex, year);
    final safeDay = hijri.day > maxDay ? maxDay : hijri.day;

    _selectedDate = _hijriToGregorian(year, monthIndex, safeDay);
  }

  @override
  void goToPreviousMonth() {
    final hijri = _gregorianToHijri(_selectedDate);

    int monthIndex = hijri.monthIndex - 1;
    int year = hijri.year;

    if (monthIndex < 0) {
      monthIndex = 11;
      year--;
    }

    final maxDay = getDaysInMonth(monthIndex, year);
    final safeDay = hijri.day > maxDay ? maxDay : hijri.day;

    _selectedDate = _hijriToGregorian(year, monthIndex, safeDay);
  }

  @override
  List<String> getMonthNames() => _months;

  @override
  int getDaysInMonth(int monthIndex, int year) {
    if (monthIndex == 11) {
      return _isHijriLeapYear(year) ? 30 : 29;
    }
    return monthIndex.isEven ? 30 : 29;
  }

  @override
  String getMonthYearLabel() {
    final hijri = _gregorianToHijri(_selectedDate);
    return "${_months[hijri.monthIndex]} ${hijri.year} AH";
  }

  @override
  String getFormattedSelectedDate() {
    final hijri = _gregorianToHijri(_selectedDate);
    return "${hijri.day} ${_months[hijri.monthIndex]} ${hijri.year} AH";
  }

  @override
  int getDisplayYear() => _gregorianToHijri(_selectedDate).year;

  @override
  int getSelectedMonthIndex() => _gregorianToHijri(_selectedDate).monthIndex;

  @override
  int getSelectedDay() => _gregorianToHijri(_selectedDate).day;

  @override
  int getTodayMonthIndex() => _gregorianToHijri(DateTime.now()).monthIndex;

  @override
  int getTodayDay() => _gregorianToHijri(DateTime.now()).day;

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final holidays = <String>[];

    if (monthIndex == 0 && day == 1) {
      holidays.add('Islamic New Year');
    }
    if (monthIndex == 2 && day == 12) {
      holidays.add('Mawlid');
    }
    if (monthIndex == 8 && day == 1) {
      holidays.add('Start of Ramadan');
    }
    if (monthIndex == 9 && day == 1) {
      holidays.add('Eid al-Fitr');
    }
    if (monthIndex == 11 && day == 10) {
      holidays.add('Eid al-Adha');
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

    if (monthIndex == 2 && day == 12) {
      events.add('Birth of Prophet Muhammad');
    }
    if (monthIndex == 8 && day == 1) {
      events.add('Month of Fasting Begins');
    }

    return events;
  }

  bool _isHijriLeapYear(int year) {
    const leapYearsInCycle = {2, 5, 7, 10, 13, 16, 18, 21, 24, 26, 29};
    final cycleYear = ((year - 1) % 30) + 1;
    return leapYearsInCycle.contains(cycleYear);
  }

  _HijriDate _gregorianToHijri(DateTime date) {
    final jd = _gregorianToJulianDay(date.year, date.month, date.day);
    final year = ((30 * (jd - 1948439) + 10646) ~/ 10631);
    final firstDayOfYear = _hijriToJulianDay(year, 0, 1);
    final month = math.min(
      11,
      (((jd - 29 - firstDayOfYear) / 29.5).ceil()).clamp(0, 11),
    );
    final firstDayOfMonth = _hijriToJulianDay(year, month, 1);
    final day = jd - firstDayOfMonth + 1;

    return _HijriDate(
      year: year,
      monthIndex: month,
      day: day,
    );
  }

  DateTime _hijriToGregorian(int year, int monthIndex, int day) {
    final jd = _hijriToJulianDay(year, monthIndex, day);
    return _julianDayToGregorian(jd);
  }

  int _gregorianToJulianDay(int year, int month, int day) {
    final a = (14 - month) ~/ 12;
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return day +
        ((153 * m + 2) ~/ 5) +
        365 * y +
        (y ~/ 4) -
        (y ~/ 100) +
        (y ~/ 400) -
        32045;
  }

  int _hijriToJulianDay(int year, int monthIndex, int day) {
    final month = monthIndex + 1;
    return day +
        ((29.5 * (month - 1)).ceil()) +
        (year - 1) * 354 +
        ((3 + 11 * year) ~/ 30) +
        1948439 -
        1;
  }

  DateTime _julianDayToGregorian(int jd) {
    final a = jd + 32044;
    final b = (4 * a + 3) ~/ 146097;
    final c = a - (146097 * b) ~/ 4;
    final d = (4 * c + 3) ~/ 1461;
    final e = c - (1461 * d) ~/ 4;
    final m = (5 * e + 2) ~/ 153;

    final day = e - (153 * m + 2) ~/ 5 + 1;
    final month = m + 3 - 12 * (m ~/ 10);
    final year = 100 * b + d - 4800 + (m ~/ 10);

    return DateTime(year, month, day);
  }
}

class _HijriDate {
  final int year;
  final int monthIndex;
  final int day;

  _HijriDate({
    required this.year,
    required this.monthIndex,
    required this.day,
  });
}

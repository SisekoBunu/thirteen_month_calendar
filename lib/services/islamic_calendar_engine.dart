import '../models/calendar_type.dart';
import 'calendar_engine.dart';
import 'islamic_timeline_service.dart';

class IslamicCalendarEngine implements CalendarEngine {
  late int _year;
  late int _month;
  late int _day;

  late final int _todayYear;
  late final int _todayMonth;
  late final int _todayDay;

  IslamicCalendarEngine() {
    final today = DateTime.now();
    final h = _fromGregorian(today);

    _todayYear = h[0];
    _todayMonth = h[1];
    _todayDay = h[2];

    _year = _todayYear;
    _month = _todayMonth;
    _day = _todayDay;
  }

  static const List<String> _months = [
    "Muharram","Safar","Rabi al-Awwal","Rabi al-Thani",
    "Jumada al-Awwal","Jumada al-Thani","Rajab","Sha'ban",
    "Ramadan","Shawwal","Dhu al-Qi'dah","Dhu al-Hijjah"
  ];

  static const Set<int> _leapYears = {
    2,5,7,10,13,16,18,21,24,26,29
  };

  @override
  CalendarType get type => CalendarType.islamic;

  @override
  String get displayName => "Islamic (Hijri)";

  @override
  DateTime get selectedGregorianDate => DateTime.now();

  @override
  void selectGregorianDate(DateTime date) {
    final h = _fromGregorian(date);
    _year = h[0];
    _month = h[1];
    _day = h[2];
  }

  @override
  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    _month = monthIndex + 1;
    final maxDay = getDaysInMonth(monthIndex, _year);
    _day = day.clamp(1, maxDay);
  }

  @override
  void goToNextMonth() {
    _month++;
    if (_month > 12) {
      _month = 1;
      _year++;
    }
    _clampDay();
  }

  @override
  void goToPreviousMonth() {
    _month--;
    if (_month < 1) {
      _month = 12;
      _year--;
    }
    _clampDay();
  }

  void _clampDay() {
    final maxDay = getDaysInMonth(_month - 1, _year);
    if (_day > maxDay) {
      _day = maxDay;
    }
  }

  bool _isLeapYear(int year) {
    final pos = ((year - 1) % 30) + 1;
    return _leapYears.contains(pos);
  }

  @override
  int getDaysInMonth(int monthIndex, int year) {
    final m = monthIndex + 1;

    if (m == 12) {
      return _isLeapYear(year) ? 30 : 29;
    }

    return (m % 2 == 1) ? 30 : 29;
  }

  @override
  List<String> getMonthNames() => _months;

  @override
  String getMonthYearLabel() =>
      "  AH";

  @override
  String getFormattedSelectedDate() =>
      "   AH";

  @override
  int getDisplayYear() => _year;

  @override
  int getSelectedMonthIndex() => _month - 1;

  @override
  int getSelectedDay() => _day;

  @override
  int getTodayMonthIndex() => _todayMonth - 1;

  @override
  int getTodayDay() => _todayDay;

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final m = monthIndex + 1;

    if (m == 1 && day == 1) return ["Islamic New Year"];
    if (m == 9 && day == 1) return ["Start of Ramadan"];
    if (m == 10 && day == 1) return ["Eid al-Fitr"];
    if (m == 12 && day == 10) return ["Eid al-Adha"];

    return const [];
  }

  @override
  List<String> getTimelineEventsForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final m = monthIndex + 1;

    return IslamicTimelineService.timelineEvents
        .where((e) => e.month == m && e.day == day)
        .map((e) => e.name)
        .toList();
  }

  List<int> _fromGregorian(DateTime date) {
    final jd = _julian(date.year, date.month, date.day);

    int l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;

    final j = (((10985 - l) / 5316).floor()) *
            (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) *
            (((43 * l) / 15238).floor());

    l = l -
        (((30 - j) / 15).floor()) *
            (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) *
            (((15238 * j) / 43).floor()) +
        29;

    final m = ((24 * l) / 709).floor();
    final d = l - ((709 * m) / 24).floor();
    final y = 30 * n + j - 30;

    return [y, m, d];
  }

  int _julian(int y, int m, int d) {
    if (m <= 2) {
      y--;
      m += 12;
    }

    final a = (y / 100).floor();
    final b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524;
  }
}

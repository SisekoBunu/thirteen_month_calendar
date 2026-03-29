import '../models/calendar_type.dart';
import 'calendar_engine.dart';

class IslamicCalendarEngine implements CalendarEngine {

  IslamicCalendarEngine() {
    final today = DateTime.now();
    final h = _fromGregorian(today);
    _year = h[0];
    _month = h[1];
    _day = h[2];
  }

  List<int> _fromGregorian(DateTime date) {
    final jd = _julianDay(date.year, date.month, date.day);

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;

    int j = (((10985 - l) / 5316).floor()) *
            (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) *
            (((43 * l) / 15238).floor());

    l = l -
        (((30 - j) / 15).floor()) *
            (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) *
            (((15238 * j) / 43).floor()) +
        29;

    int m = ((24 * l) / 709).floor();
    int d = l - ((709 * m) / 24).floor();
    int y = 30 * n + j - 30;

    return [y, m, d];
  }

  int _julianDay(int y, int m, int d) {
    if (m <= 2) {
      y -= 1;
      m += 12;
    }

    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();

    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        d +
        b -
        1524;
  }


  int _year = 1447;
  int _month = 1;
  int _day = 1;

  @override
  CalendarType get type => CalendarType.islamic;

  @override
  String get displayName => "Islamic (Hijri)";

  @override
  DateTime get selectedGregorianDate => DateTime.now(); // unused

  @override
  void selectGregorianDate(DateTime date) {}

  @override
  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    _month = monthIndex + 1;
    _day = day;
  }

  @override
  void goToNextMonth() {
    _month++;
    if (_month > 12) {
      _month = 1;
      _year++;
    }
  }

  @override
  void goToPreviousMonth() {
    _month--;
    if (_month < 1) {
      _month = 12;
      _year--;
    }
  }

  @override
  String getMonthYearLabel() {
    return "  AH";
  }

  @override
  String getFormattedSelectedDate() {
    return "   AH";
  }

  @override
  int getDisplayYear() => _year;

  @override
  int getSelectedMonthIndex() => _month - 1;

  @override
  int getSelectedDay() => _day;

  @override
  int getTodayMonthIndex() => _month - 1;

  @override
  int getTodayDay() => _day;

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
    "Dhu al-Qi'dah",
    "Dhu al-Hijjah"
  ];

  @override
  List<String> getMonthNames() => _months;

  @override
  int getDaysInMonth(int monthIndex, int year) {
    return (monthIndex % 2 == 0) ? 30 : 29;
  }

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final events = <String>[];

    final m = monthIndex + 1;

    if (m == 1 && day == 1) events.add("Islamic New Year");
    if (m == 1 && day == 10) events.add("Ashura");
    if (m == 3 && day == 12) events.add("Mawlid al-Nabi");
    if (m == 8 && day == 15) events.add("Laylat al-Barat");
    if (m == 9 && day == 1) events.add("Start of Ramadan");
    if (m == 9 && day == 27) events.add("Laylat al-Qadr");
    if (m == 10 && day == 1) events.add("Eid al-Fitr");
    if (m == 12 && day == 9) events.add("Day of Arafah");
    if (m == 12 && day == 10) events.add("Eid al-Adha");

    return events;
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




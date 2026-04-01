import '../models/calendar_type.dart';
import 'calendar_engine.dart';

class JewishCalendarEngine implements CalendarEngine {

  int _year = 5786;
  int _month = 7; // Nisan
  int _day = 23;

  static const List<String> _months = [
    "Tishrei","Cheshvan","Kislev","Tevet",
    "Shevat","Adar I","Adar II","Nisan","Iyar",
    "Sivan","Tammuz","Av","Elul"
  ];

  bool _isLeapYear(int year) {
    final mod19 = year % 19;
    return [0,3,6,8,11,14,17].contains(mod19);
  }

  @override
  CalendarType get type => CalendarType.jewish;

  @override
  String get displayName => "Jewish (Hebrew)";

  @override
  DateTime get selectedGregorianDate => DateTime.now();

  @override
  void selectGregorianDate(DateTime date) {}

  @override
  void selectCalendarDate({
    required int monthIndex,
    required int day,
  }) {
    _month = monthIndex + 1;
    _day = day.clamp(1, getDaysInMonth(monthIndex, _year));
  }

  @override
  void goToNextMonth() {
    final maxMonths = _isLeapYear(_year) ? 13 : 12;
    _month++;
    if (_month > maxMonths) {
      _month = 1;
      _year++;
    }
  }

  @override
  void goToPreviousMonth() {
    _month--;
    if (_month < 1) {
      _year--;
      _month = _isLeapYear(_year) ? 13 : 12;
    }
  }

  @override
  List<String> getMonthNames() {
    if (_isLeapYear(_year)) {
      return _months;
    } else {
      return _months.where((m) => m != "Adar I").toList();
    }
  }

  @override
  int getDaysInMonth(int monthIndex, int year) {
    final isLeap = _isLeapYear(year);

    final lengths = isLeap
        ? [30,29,30,29,30,30,29,30,29,30,29,30,29]
        : [30,29,30,29,30,29,30,29,30,29,30,29];

    return lengths[monthIndex];
  }

  @override
  String getFormattedSelectedDate() {
    return "\ \ \ AM";
  }

  @override
  String getMonthYearLabel() {
    return "\ \ AM";
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

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    final month = getMonthNames()[monthIndex];

    if (month == "Tishrei" && (day == 1 || day == 2)) return ["Rosh Hashanah"];
    if (month == "Tishrei" && day == 10) return ["Yom Kippur"];
    if (month == "Tishrei" && day >= 15 && day <= 21) return ["Sukkot"];

    if (month == "Kislev" && day >= 25) return ["Hanukkah"];
    if (month == "Tevet" && day <= 2) return ["Hanukkah"];

    if (month.contains("Adar") && day == 14) return ["Purim"];

    if (month == "Nisan" && day >= 15 && day <= 21) return ["Passover"];

    if (month == "Sivan" && day == 6) return ["Shavuot"];

    if (month == "Av" && day == 9) return ["Tisha B'Av"];

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

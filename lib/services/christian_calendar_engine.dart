import 'gregorian_calendar_engine.dart';
import '../models/calendar_type.dart';

class ChristianCalendarEngine extends GregorianCalendarEngine {

  @override
  CalendarType get type => CalendarType.christian;

  @override
  String get displayName => "Christian (Ussher Chronology)";

  @override
  int getDisplayYear() => selectedGregorianDate.year + 4003;

  @override
  String getMonthYearLabel() {
    final gDate = selectedGregorianDate;
    final amYear = gDate.year + 4003;
    return " ";
  }

  @override
  String getFormattedSelectedDate() {
    final gDate = selectedGregorianDate;
    final amYear = gDate.year + 4003;
    return "  ";
  }

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    final holidays = super.getHolidaysForDate(
      year: year,
      monthIndex: monthIndex,
      day: day,
    );

    if (day == null) return holidays;

    final month = monthIndex + 1;

    DateTime getEaster(int year) {
      final a = year % 19;
      final b = year ~/ 100;
      final c = year % 100;
      final d = b ~/ 4;
      final e = b % 4;
      final f = (b + 8) ~/ 25;
      final g = (b - f + 1) ~/ 3;
      final h = (19 * a + b - d - g + 15) % 30;
      final i = c ~/ 4;
      final k = c % 4;
      final l = (32 + 2 * e + 2 * i - h - k) % 7;
      final m = (a + 11 * h + 22 * l) ~/ 451;
      final easterMonth = (h + l - 7 * m + 114) ~/ 31;
      final easterDay = ((h + l - 7 * m + 114) % 31) + 1;
      return DateTime(year, easterMonth, easterDay);
    }

    final easter = getEaster(year);

    final ashWednesday = easter.subtract(const Duration(days: 46));
    final palmSunday = easter.subtract(const Duration(days: 7));
    final maundyThursday = easter.subtract(const Duration(days: 3));
    final ascensionDay = easter.add(const Duration(days: 39));
    final pentecost = easter.add(const Duration(days: 49));

    if (monthIndex == ashWednesday.month - 1 && day == ashWednesday.day) {
      holidays.add("Ash Wednesday");
    }

    if (monthIndex == palmSunday.month - 1 && day == palmSunday.day) {
      holidays.add("Palm Sunday");
    }

    if (monthIndex == maundyThursday.month - 1 && day == maundyThursday.day) {
      holidays.add("Maundy Thursday");
    }

    if (monthIndex == easter.month - 1 && day == easter.day) {
      holidays.add("Easter Sunday");
      holidays.add("Resurrection of Jesus");
    }

    if (monthIndex == ascensionDay.month - 1 && day == ascensionDay.day) {
      holidays.add("Ascension Day");
    }

    if (monthIndex == pentecost.month - 1 && day == pentecost.day) {
      holidays.add("Pentecost");
    }

    if (month == 1 && day == 6) holidays.add("Epiphany");
    if (month == 11 && day == 1) holidays.add("All Saints' Day");

    if (month == 1 && day == 1) {
      holidays.add("Creation of the World (Approx.)");
    }

    if (month == 1 && day == 10) {
      holidays.add("Baptism of Jesus (Approx.)");
    }

    if (month == 2 && day == 17) {
      holidays.add("Noah's Flood Begins (Approx.)");
    }

    if (month == 4 && day == 15) {
      holidays.add("Exodus (Approx.)");
    }

    if (month == 9 && day == 1) {
      holidays.add("Call of Abraham (Approx.)");
    }

    if (month == 12 && day == 25) {
      holidays.add("Birth of Jesus (Tradition)");
    }

    return holidays;
  }
}

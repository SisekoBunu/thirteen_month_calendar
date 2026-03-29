import 'gregorian_calendar_engine.dart';
import '../models/calendar_type.dart';

class ChristianCalendarEngine extends GregorianCalendarEngine {
  static const int _ussherOffset = 4003;

  @override
  CalendarType get type => CalendarType.christian;

  @override
  String get displayName => "Christian (Ussher Chronology)";

  @override
  int getDisplayYear() => selectedGregorianDate.year + _ussherOffset;

  @override
  String getMonthYearLabel() {
    final gDate = selectedGregorianDate;
    final amYear = gDate.year + _ussherOffset;
    return "${getMonthNames()[gDate.month - 1]} $amYear";
  }

  @override
  String getFormattedSelectedDate() {
    final gDate = selectedGregorianDate;
    final amYear = gDate.year + _ussherOffset;
    return "${gDate.day} ${getMonthNames()[gDate.month - 1]} $amYear";
  }

  @override
  List<String> getHolidaysForDate({
    required int year,
    required int monthIndex,
    required int? day,
  }) {
    if (day == null) return const [];

    // Convert displayed AM year back to Gregorian year for calculations.
    final gregorianYear = year - _ussherOffset;
    final month = monthIndex + 1;
    final holidays = <String>[];

    // Pull Gregorian observances using the Gregorian year, not the AM year.
    holidays.addAll(
      super.getHolidaysForDate(
        year: gregorianYear,
        monthIndex: monthIndex,
        day: day,
      ),
    );

    DateTime getEaster(int y) {
      final a = y % 19;
      final b = y ~/ 100;
      final c = y % 100;
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
      return DateTime(y, easterMonth, easterDay);
    }

    final easter = getEaster(gregorianYear);
    final ashWednesday = easter.subtract(const Duration(days: 46));
    final palmSunday = easter.subtract(const Duration(days: 7));
    final maundyThursday = easter.subtract(const Duration(days: 3));
    final goodFriday = easter.subtract(const Duration(days: 2));
    final easterMonday = easter.add(const Duration(days: 1));
    final ascensionDay = easter.add(const Duration(days: 39));
    final pentecost = easter.add(const Duration(days: 49));

    // Liturgical cycle
    if (monthIndex == ashWednesday.month - 1 && day == ashWednesday.day) {
      holidays.add("Ash Wednesday");
    }
    if (monthIndex == palmSunday.month - 1 && day == palmSunday.day) {
      holidays.add("Palm Sunday");
    }
    if (monthIndex == maundyThursday.month - 1 && day == maundyThursday.day) {
      holidays.add("Maundy Thursday");
    }
    if (monthIndex == goodFriday.month - 1 && day == goodFriday.day) {
      holidays.add("Crucifixion of Jesus (Tradition)");
    }
    if (monthIndex == easter.month - 1 && day == easter.day) {
      holidays.add("Resurrection of Jesus");
    }
    if (monthIndex == easterMonday.month - 1 && day == easterMonday.day) {
      // Gregorian already adds Easter Monday; avoid duplicate
    }
    if (monthIndex == ascensionDay.month - 1 && day == ascensionDay.day) {
      holidays.add("Ascension Day");
    }
    if (monthIndex == pentecost.month - 1 && day == pentecost.day) {
      holidays.add("Pentecost");
    }

    // Fixed Christian observances
    if (month == 1 && day == 6) holidays.add("Epiphany");
    if (month == 11 && day == 1) holidays.add("All Saints' Day");

    // Timeline events with context
    if (month == 1 && day == 1) {
      holidays.add("Creation of the World (Beginning of Creation Era, Approx.)");
    }
    if (month == 1 && day == 2) {
      holidays.add("Creation of Adam (Same creation period, Approx.)");
    }
    if (month == 1 && day == 3) {
      holidays.add("Creation of Eve (Shortly after Adam, Approx.)");
    }
    if (month == 1 && day == 4) {
      holidays.add("Fall of Man (Adam and Eve cast out of Eden, Shortly after creation, Approx.)");
    }

    if (month == 3 && day == 15) {
      holidays.add("Tower of Babel Begins (Generations after the Flood)");
    }
    if (month == 3 && day == 16) {
      holidays.add("Rise of Nimrod (Leader during Babel era)");
    }
    if (month == 3 && day == 20) {
      holidays.add("Fall of the Tower of Babel (Languages divided)");
    }

    if (month == 9 && day == 1) {
      holidays.add("Call of Abraham (~75 years after birth)");
    }
    if (month == 10 && day == 1) {
      holidays.add("Birth of Abraham (Approx.)");
    }

    if (month == 4 && day == 1) {
      holidays.add("Ten Plagues Begin (Moses vs Pharaoh)");
    }
    if (month == 4 && day == 10) {
      holidays.add("Exodus Begins (Israelites leave Egypt)");
    }
    if (month == 4 && day == 14) {
      holidays.add("Moses Parts the Red Sea");
    }

    if (month == 6 && day == 10) {
      holidays.add("David defeats Goliath (Approx.)");
    }
    if (month == 7 && day == 1) {
      holidays.add("Reign of King Solomon Begins");
    }

    if (month == 1 && day == 10) {
      holidays.add("Baptism of Jesus (Approx.)");
    }
    if (month == 9 && day == 8) {
      holidays.add("Birth of Mary (Tradition)");
    }
    if (month == 12 && day == 25) {
      holidays.add("Birth of Jesus (Tradition)");
    }

    return holidays;
  }
}


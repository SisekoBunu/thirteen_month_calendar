import 'culture_config.dart';

class CustomCalendarDate {
  final int year;
  final int? monthIndex;
  final int? day;
  final bool isYearDay;
  final bool isLeapDay;

  const CustomCalendarDate({
    required this.year,
    required this.monthIndex,
    required this.day,
    required this.isYearDay,
    required this.isLeapDay,
  });

  bool get isRegularMonthDay => monthIndex != null && day != null;
}

class CalendarLogic {
  static final DateTime _epoch = DateTime.utc(1, 4, 1);

  static bool isGregorianLeapYear(int year) {
    if (year % 400 == 0) return true;
    if (year % 100 == 0) return false;
    return year % 4 == 0;
  }

  static bool isCustomLeapYear(int customYear) {
    return isGregorianLeapYear(customYear + 1);
  }

  static int daysInCustomYear(int customYear) {
    return 364 + 1 + (isCustomLeapYear(customYear) ? 1 : 0);
  }

  static CustomCalendarDate convertGregorianToCustomDate(DateTime gregorianDate) {
    final target = DateTime.utc(
      gregorianDate.year,
      gregorianDate.month,
      gregorianDate.day,
    );

    final int elapsedDays = target.difference(_epoch).inDays;

    int remaining = elapsedDays;
    int customYear = 1;

    while (true) {
      final yearLength = daysInCustomYear(customYear);
      if (remaining < yearLength) break;
      remaining -= yearLength;
      customYear++;
    }

    if (remaining < 364) {
      final int monthIndex = remaining ~/ 28;
      final int day = (remaining % 28) + 1;

      return CustomCalendarDate(
        year: customYear,
        monthIndex: monthIndex,
        day: day,
        isYearDay: false,
        isLeapDay: false,
      );
    }

    remaining -= 364;

    if (remaining == 0) {
      return CustomCalendarDate(
        year: customYear,
        monthIndex: null,
        day: null,
        isYearDay: true,
        isLeapDay: false,
      );
    }

    if (isCustomLeapYear(customYear) && remaining == 1) {
      return CustomCalendarDate(
        year: customYear,
        monthIndex: null,
        day: null,
        isYearDay: false,
        isLeapDay: true,
      );
    }

    return CustomCalendarDate(
      year: customYear,
      monthIndex: 12,
      day: 28,
      isYearDay: false,
      isLeapDay: false,
    );
  }

  static DateTime convertCustomToGregorianDate(
    int customYear,
    int monthIndex,
    int day,
  ) {
    int days = 0;

    for (int y = 1; y < customYear; y++) {
      days += daysInCustomYear(y);
    }

    days += (monthIndex * 28);
    days += (day - 1);

    return _epoch.add(Duration(days: days));
  }

  static CustomCalendarDate currentCustomDate() {
    return convertGregorianToCustomDate(DateTime.now().toUtc());
  }

  static String displayedYearForCulture(String culture, int cycleYear) {
    final config = CultureRegistry.cultures[culture];

    if (config == null) {
      return cycleYear.toString();
    }

    switch (config.eraSystem) {
      case EraSystem.astronomical:
        return cycleYear.toString();

      case EraSystem.offset:
        final adjusted = cycleYear + config.yearOffset;
        return adjusted.toString();

      case EraSystem.christianUssher:
        final adjusted = cycleYear + config.yearOffset;
        return adjusted.toString();
    }
  }
}

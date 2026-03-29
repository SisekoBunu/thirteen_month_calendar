class HijriDate {
  final int year;
  final int month;
  final int day;

  const HijriDate(this.year, this.month, this.day);
}

class HijriConverter {
  static HijriDate fromGregorian(DateTime date) {
    final jd = _gregorianToJulianDay(date.year, date.month, date.day);
    return _julianDayToHijri(jd);
  }

  static DateTime toGregorian(int hijriYear, int hijriMonth, int hijriDay) {
    final jd = _hijriToJulianDay(hijriYear, hijriMonth, hijriDay);
    return _julianDayToGregorian(jd);
  }

  static bool isLeapYear(int hijriYear) {
    return ((11 * hijriYear + 14) % 30) < 11;
  }

  static int daysInMonth(int hijriYear, int hijriMonth) {
    if (hijriMonth == 12) {
      return isLeapYear(hijriYear) ? 30 : 29;
    }
    return (hijriMonth % 2 == 1) ? 30 : 29;
  }

  static int _gregorianToJulianDay(int year, int month, int day) {
    final a = ((14 - month) / 12).floor();
    final y = year + 4800 - a;
    final m = month + 12 * a - 3;

    return day +
        ((153 * m + 2) / 5).floor() +
        365 * y +
        (y / 4).floor() -
        (y / 100).floor() +
        (y / 400).floor() -
        32045;
  }

  static DateTime _julianDayToGregorian(int jd) {
    final a = jd + 32044;
    final b = ((4 * a + 3) / 146097).floor();
    final c = a - ((146097 * b) / 4).floor();

    final d = ((4 * c + 3) / 1461).floor();
    final e = c - ((1461 * d) / 4).floor();
    final m = ((5 * e + 2) / 153).floor();

    final day = e - ((153 * m + 2) / 5).floor() + 1;
    final month = m + 3 - 12 * (m / 10).floor();
    final year = 100 * b + d - 4800 + (m / 10).floor();

    return DateTime(year, month, day);
  }

  static int _hijriToJulianDay(int year, int month, int day) {
    return day +
        (29.5 * (month - 1)).ceil() +
        (year - 1) * 354 +
        ((3 + 11 * year) / 30).floor() +
        1948439;
  }

  static HijriDate _julianDayToHijri(int jd) {
    final year = ((30 * (jd - 1948439) + 10646) / 10631).floor();
    final firstDayOfYear = _hijriToJulianDay(year, 1, 1);

    int month = (((jd - 29 - firstDayOfYear) / 29.5).ceil() + 1).clamp(1, 12);
    if (month > 12) month = 12;

    final firstDayOfMonth = _hijriToJulianDay(year, month, 1);
    final day = jd - firstDayOfMonth + 1;

    return HijriDate(year, month, day);
  }
}

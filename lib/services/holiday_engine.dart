import '../models/holiday_item.dart';
import 'calendar_logic.dart';

class HolidayEngine {
  static const List<HolidayItem> baseGregorianHolidays = [
    HolidayItem(name: "New Year's Day", gregorianMonth: 1, gregorianDay: 1, profile: 'Gregorian'),
    HolidayItem(name: "Valentine's Day", gregorianMonth: 2, gregorianDay: 14, profile: 'Gregorian'),
    HolidayItem(name: "International Women's Day", gregorianMonth: 3, gregorianDay: 8, profile: 'Gregorian'),
    HolidayItem(name: "Earth Day", gregorianMonth: 4, gregorianDay: 22, profile: 'Gregorian'),
    HolidayItem(name: "International Workers' Day", gregorianMonth: 5, gregorianDay: 1, profile: 'Gregorian'),
    HolidayItem(name: "World Environment Day", gregorianMonth: 6, gregorianDay: 5, profile: 'Gregorian'),
    HolidayItem(name: "International Day of Peace", gregorianMonth: 9, gregorianDay: 21, profile: 'Gregorian'),
    HolidayItem(name: "United Nations Day", gregorianMonth: 10, gregorianDay: 24, profile: 'Gregorian'),
    HolidayItem(name: "Halloween", gregorianMonth: 10, gregorianDay: 31, profile: 'Gregorian'),
    HolidayItem(name: "Human Rights Day", gregorianMonth: 12, gregorianDay: 10, profile: 'Gregorian'),
    HolidayItem(name: "Christmas Day", gregorianMonth: 12, gregorianDay: 25, profile: 'Gregorian'),
    HolidayItem(name: "New Year's Eve", gregorianMonth: 12, gregorianDay: 31, profile: 'Gregorian'),
  ];

  static const List<HolidayItem> usaHolidays = [
    HolidayItem(name: "Independence Day", gregorianMonth: 7, gregorianDay: 4, profile: 'Gregorian', country: 'USA'),
    HolidayItem(name: "Veterans Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'USA'),
    HolidayItem(name: "Pearl Harbor Remembrance Day", gregorianMonth: 12, gregorianDay: 7, profile: 'Gregorian', country: 'USA'),
  ];

  static const List<HolidayItem> ukHolidays = [
    HolidayItem(name: "St George's Day", gregorianMonth: 4, gregorianDay: 23, profile: 'Gregorian', country: 'United Kingdom'),
    HolidayItem(name: "Guy Fawkes Night", gregorianMonth: 11, gregorianDay: 5, profile: 'Gregorian', country: 'United Kingdom'),
    HolidayItem(name: "Remembrance Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'United Kingdom'),
  ];

  static const List<HolidayItem> canadaHolidays = [
    HolidayItem(name: "Canada Day", gregorianMonth: 7, gregorianDay: 1, profile: 'Gregorian', country: 'Canada'),
    HolidayItem(name: "Remembrance Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'Canada'),
    HolidayItem(name: "National Indigenous Peoples Day", gregorianMonth: 6, gregorianDay: 21, profile: 'Gregorian', country: 'Canada'),
  ];

  static const List<HolidayItem> australiaHolidays = [
    HolidayItem(name: "Australia Day", gregorianMonth: 1, gregorianDay: 26, profile: 'Gregorian', country: 'Australia'),
    HolidayItem(name: "ANZAC Day", gregorianMonth: 4, gregorianDay: 25, profile: 'Gregorian', country: 'Australia'),
    HolidayItem(name: "Remembrance Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'Australia'),
  ];

  static const List<HolidayItem> newZealandHolidays = [
    HolidayItem(name: "Waitangi Day", gregorianMonth: 2, gregorianDay: 6, profile: 'Gregorian', country: 'New Zealand'),
    HolidayItem(name: "ANZAC Day", gregorianMonth: 4, gregorianDay: 25, profile: 'Gregorian', country: 'New Zealand'),
    HolidayItem(name: "Remembrance Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'New Zealand'),
  ];

  static const List<HolidayItem> southAfricaHolidays = [
    HolidayItem(name: "Human Rights Day", gregorianMonth: 3, gregorianDay: 21, profile: 'Gregorian', country: 'South Africa'),
    HolidayItem(name: "Freedom Day", gregorianMonth: 4, gregorianDay: 27, profile: 'Gregorian', country: 'South Africa'),
    HolidayItem(name: "Youth Day", gregorianMonth: 6, gregorianDay: 16, profile: 'Gregorian', country: 'South Africa'),
    HolidayItem(name: "Heritage Day", gregorianMonth: 9, gregorianDay: 24, profile: 'Gregorian', country: 'South Africa'),
    HolidayItem(name: "Day of Reconciliation", gregorianMonth: 12, gregorianDay: 16, profile: 'Gregorian', country: 'South Africa'),
  ];

  static List<HolidayItem> getGregorianHolidays({String? country}) {
    final List<HolidayItem> holidays = [...baseGregorianHolidays];

    switch (country) {
      case 'USA':
        holidays.addAll(usaHolidays);
        break;
      case 'United Kingdom':
        holidays.addAll(ukHolidays);
        break;
      case 'Canada':
        holidays.addAll(canadaHolidays);
        break;
      case 'Australia':
        holidays.addAll(australiaHolidays);
        break;
      case 'New Zealand':
        holidays.addAll(newZealandHolidays);
        break;
      case 'South Africa':
        holidays.addAll(southAfricaHolidays);
        break;
      case 'International':
      default:
        break;
    }

    return holidays;
  }

  static List<String> getHolidayNamesForCurrentSelection({
    required String profile,
    required String? country,
    required int customYear,
    required int customMonthIndex,
    required int? customDay,
  }) {
    if (profile != 'Gregorian' || customDay == null) {
      return [];
    }

    final holidays = getGregorianHolidays(country: country);

    return holidays.where((holiday) {
      final int gregorianYear =
          holiday.gregorianMonth >= 4 ? customYear : customYear + 1;

      final mapped = CalendarLogic.convertGregorianToCustomDate(
        DateTime.utc(
          gregorianYear,
          holiday.gregorianMonth,
          holiday.gregorianDay,
        ),
      );

      if (!mapped.isRegularMonthDay) return false;

      return mapped.year == customYear &&
          mapped.monthIndex == customMonthIndex &&
          mapped.day == customDay;
    }).map((holiday) => holiday.name).toList();
  }
}

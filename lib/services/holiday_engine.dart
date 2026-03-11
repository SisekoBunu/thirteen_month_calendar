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

  static int? _nominalGregorianMonthForCustomMonthIndex(int customMonthIndex) {
    const monthMap = <int, int?>{
      0: 4,   // April
      1: 5,   // May
      2: 6,   // June
      3: 7,   // July
      4: 8,   // August
      5: null, // Sol
      6: 9,   // September
      7: 10,  // October
      8: 11,  // November
      9: 12,  // December
      10: 1,  // January
      11: 2,  // February
      12: 3,  // March
    };

    return monthMap[customMonthIndex];
  }

  static int _gregorianYearForHolidayInCustomYear(int customYear, int gregorianMonth) {
    return gregorianMonth >= 4 ? customYear : customYear + 1;
  }

  static List<HolidayItem> _countryRecurringHolidays(String? country) {
    switch (country) {
      case 'South Africa':
        return const [
          HolidayItem(name: "Human Rights Day", gregorianMonth: 3, gregorianDay: 21, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "Freedom Day", gregorianMonth: 4, gregorianDay: 27, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "Workers' Day", gregorianMonth: 5, gregorianDay: 1, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "Youth Day", gregorianMonth: 6, gregorianDay: 16, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "National Women's Day", gregorianMonth: 8, gregorianDay: 9, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "Heritage Day", gregorianMonth: 9, gregorianDay: 24, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "Day of Reconciliation", gregorianMonth: 12, gregorianDay: 16, profile: 'Gregorian', country: 'South Africa'),
          HolidayItem(name: "Day of Goodwill", gregorianMonth: 12, gregorianDay: 26, profile: 'Gregorian', country: 'South Africa'),
        ];
      case 'USA':
        return const [
          HolidayItem(name: "Independence Day", gregorianMonth: 7, gregorianDay: 4, profile: 'Gregorian', country: 'USA'),
          HolidayItem(name: "Veterans Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'USA'),
          HolidayItem(name: "Halloween", gregorianMonth: 10, gregorianDay: 31, profile: 'Gregorian', country: 'USA'),
        ];
      case 'United Kingdom':
        return const [
          HolidayItem(name: "St George's Day", gregorianMonth: 4, gregorianDay: 23, profile: 'Gregorian', country: 'United Kingdom'),
          HolidayItem(name: "St Andrew's Day", gregorianMonth: 11, gregorianDay: 30, profile: 'Gregorian', country: 'United Kingdom'),
          HolidayItem(name: "St Patrick's Day", gregorianMonth: 3, gregorianDay: 17, profile: 'Gregorian', country: 'United Kingdom'),
        ];
      case 'Canada':
        return const [
          HolidayItem(name: "New Year's Day", gregorianMonth: 1, gregorianDay: 1, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "Canada Day", gregorianMonth: 7, gregorianDay: 1, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "National Indigenous Peoples Day", gregorianMonth: 6, gregorianDay: 21, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "National Day for Truth and Reconciliation", gregorianMonth: 9, gregorianDay: 30, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "Halloween", gregorianMonth: 10, gregorianDay: 31, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "Remembrance Day", gregorianMonth: 11, gregorianDay: 11, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "Christmas Eve", gregorianMonth: 12, gregorianDay: 24, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "Christmas Day", gregorianMonth: 12, gregorianDay: 25, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "Boxing Day", gregorianMonth: 12, gregorianDay: 26, profile: 'Gregorian', country: 'Canada'),
          HolidayItem(name: "New Year's Eve", gregorianMonth: 12, gregorianDay: 31, profile: 'Gregorian', country: 'Canada'),
        ];
      case 'Australia':
        return const [
          HolidayItem(name: "Australia Day", gregorianMonth: 1, gregorianDay: 26, profile: 'Gregorian', country: 'Australia'),
          HolidayItem(name: "ANZAC Day", gregorianMonth: 4, gregorianDay: 25, profile: 'Gregorian', country: 'Australia'),
          HolidayItem(name: "Christmas Day", gregorianMonth: 12, gregorianDay: 25, profile: 'Gregorian', country: 'Australia'),
          HolidayItem(name: "Boxing Day / Proclamation Day", gregorianMonth: 12, gregorianDay: 26, profile: 'Gregorian', country: 'Australia'),
        ];
      case 'New Zealand':
        return const [
          HolidayItem(name: "New Year's Day", gregorianMonth: 1, gregorianDay: 1, profile: 'Gregorian', country: 'New Zealand'),
          HolidayItem(name: "Day After New Year's Day", gregorianMonth: 1, gregorianDay: 2, profile: 'Gregorian', country: 'New Zealand'),
          HolidayItem(name: "Waitangi Day", gregorianMonth: 2, gregorianDay: 6, profile: 'Gregorian', country: 'New Zealand'),
          HolidayItem(name: "ANZAC Day", gregorianMonth: 4, gregorianDay: 25, profile: 'Gregorian', country: 'New Zealand'),
          HolidayItem(name: "Labour Day", gregorianMonth: 10, gregorianDay: 26, profile: 'Gregorian', country: 'New Zealand'),
          HolidayItem(name: "Christmas Day", gregorianMonth: 12, gregorianDay: 25, profile: 'Gregorian', country: 'New Zealand'),
          HolidayItem(name: "Boxing Day", gregorianMonth: 12, gregorianDay: 26, profile: 'Gregorian', country: 'New Zealand'),
        ];
      case 'International':
      default:
        return const [];
    }
  }

  static List<HolidayItem> _countryYearSpecificHolidays(String? country, int customYear) {
    switch (country) {
      case 'South Africa':
        switch (customYear) {
          case 2026:
            return const [
              HolidayItem(name: "Good Friday", gregorianMonth: 4, gregorianDay: 3, profile: 'Gregorian', country: 'South Africa'),
              HolidayItem(name: "Family Day", gregorianMonth: 4, gregorianDay: 6, profile: 'Gregorian', country: 'South Africa'),
              HolidayItem(name: "Public Holiday (Women's Day observed)", gregorianMonth: 8, gregorianDay: 10, profile: 'Gregorian', country: 'South Africa'),
            ];
          case 2027:
            return const [
              HolidayItem(name: "Public Holiday (Human Rights Day observed)", gregorianMonth: 3, gregorianDay: 22, profile: 'Gregorian', country: 'South Africa'),
              HolidayItem(name: "Good Friday", gregorianMonth: 3, gregorianDay: 26, profile: 'Gregorian', country: 'South Africa'),
              HolidayItem(name: "Easter Sunday", gregorianMonth: 3, gregorianDay: 28, profile: 'Gregorian', country: 'South Africa'),
              HolidayItem(name: "Family Day", gregorianMonth: 3, gregorianDay: 29, profile: 'Gregorian', country: 'South Africa'),
            ];
          default:
            return const [];
        }

      case 'USA':
        switch (customYear) {
          case 2026:
            return const [
              HolidayItem(name: "MLK Jr. Birthday", gregorianMonth: 1, gregorianDay: 19, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Washington's Birthday", gregorianMonth: 2, gregorianDay: 16, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Memorial Day", gregorianMonth: 5, gregorianDay: 25, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Juneteenth", gregorianMonth: 6, gregorianDay: 19, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Independence Day (Observed)", gregorianMonth: 7, gregorianDay: 3, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Labor Day", gregorianMonth: 9, gregorianDay: 7, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Columbus Day", gregorianMonth: 10, gregorianDay: 12, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Thanksgiving", gregorianMonth: 11, gregorianDay: 26, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Christmas", gregorianMonth: 12, gregorianDay: 25, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Easter", gregorianMonth: 4, gregorianDay: 5, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Mother's Day", gregorianMonth: 5, gregorianDay: 10, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Father's Day", gregorianMonth: 6, gregorianDay: 21, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Election Day", gregorianMonth: 11, gregorianDay: 3, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Pearl Harbor Remembrance Day", gregorianMonth: 12, gregorianDay: 7, profile: 'Gregorian', country: 'USA'),
            ];
          case 2027:
            return const [
              HolidayItem(name: "MLK Jr. Birthday", gregorianMonth: 1, gregorianDay: 18, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Washington's Birthday", gregorianMonth: 2, gregorianDay: 15, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Memorial Day", gregorianMonth: 5, gregorianDay: 31, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Juneteenth (Observed)", gregorianMonth: 6, gregorianDay: 18, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Independence Day (Observed)", gregorianMonth: 7, gregorianDay: 5, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Labor Day", gregorianMonth: 9, gregorianDay: 6, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Columbus Day", gregorianMonth: 10, gregorianDay: 11, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Thanksgiving", gregorianMonth: 11, gregorianDay: 25, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Christmas (Observed)", gregorianMonth: 12, gregorianDay: 24, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Easter", gregorianMonth: 3, gregorianDay: 28, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Mother's Day", gregorianMonth: 5, gregorianDay: 9, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Father's Day", gregorianMonth: 6, gregorianDay: 20, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Election Day", gregorianMonth: 11, gregorianDay: 2, profile: 'Gregorian', country: 'USA'),
              HolidayItem(name: "Pearl Harbor Remembrance Day", gregorianMonth: 12, gregorianDay: 7, profile: 'Gregorian', country: 'USA'),
            ];
          default:
            return const [];
        }

      case 'Canada':
        switch (customYear) {
          case 2026:
            return const [
              HolidayItem(name: "Family Day", gregorianMonth: 2, gregorianDay: 16, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Good Friday", gregorianMonth: 4, gregorianDay: 3, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Easter Sunday", gregorianMonth: 4, gregorianDay: 5, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 4, gregorianDay: 6, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Victoria Day", gregorianMonth: 5, gregorianDay: 18, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Civic / Provincial Day", gregorianMonth: 8, gregorianDay: 3, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Labour Day", gregorianMonth: 9, gregorianDay: 7, profile: 'Gregorian', country: 'Canada'),
              HolidayItem(name: "Thanksgiving Day", gregorianMonth: 10, gregorianDay: 12, profile: 'Gregorian', country: 'Canada'),
            ];
          default:
            return const [];
        }

      case 'United Kingdom':
        switch (customYear) {
          case 2026:
            return const [
              HolidayItem(name: "Good Friday", gregorianMonth: 4, gregorianDay: 3, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 4, gregorianDay: 6, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Early May Bank Holiday", gregorianMonth: 5, gregorianDay: 4, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Spring Bank Holiday", gregorianMonth: 5, gregorianDay: 25, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Summer Bank Holiday", gregorianMonth: 8, gregorianDay: 31, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Boxing Day (Substitute Day)", gregorianMonth: 12, gregorianDay: 28, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Battle of the Boyne", gregorianMonth: 7, gregorianDay: 13, profile: 'Gregorian', country: 'United Kingdom'),
            ];
          case 2027:
            return const [
              HolidayItem(name: "Good Friday", gregorianMonth: 3, gregorianDay: 26, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 3, gregorianDay: 29, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Early May Bank Holiday", gregorianMonth: 5, gregorianDay: 3, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Spring Bank Holiday", gregorianMonth: 5, gregorianDay: 31, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Summer Bank Holiday", gregorianMonth: 8, gregorianDay: 30, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Christmas Day (Substitute Day)", gregorianMonth: 12, gregorianDay: 27, profile: 'Gregorian', country: 'United Kingdom'),
              HolidayItem(name: "Boxing Day (Substitute Day)", gregorianMonth: 12, gregorianDay: 28, profile: 'Gregorian', country: 'United Kingdom'),
            ];
          default:
            return const [];
        }

      case 'Australia':
        switch (customYear) {
          case 2026:
            return const [
              HolidayItem(name: "Good Friday", gregorianMonth: 4, gregorianDay: 3, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 4, gregorianDay: 6, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "ANZAC Day (Observed in some states)", gregorianMonth: 4, gregorianDay: 27, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "Boxing Day / Proclamation Day (Observed)", gregorianMonth: 12, gregorianDay: 28, profile: 'Gregorian', country: 'Australia'),
            ];
          case 2027:
            return const [
              HolidayItem(name: "Good Friday", gregorianMonth: 3, gregorianDay: 26, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 3, gregorianDay: 29, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "ANZAC Day (Observed)", gregorianMonth: 4, gregorianDay: 26, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "Boxing Day / Proclamation Day (Observed)", gregorianMonth: 12, gregorianDay: 27, profile: 'Gregorian', country: 'Australia'),
              HolidayItem(name: "Additional Boxing Day / Proclamation Day Observed", gregorianMonth: 12, gregorianDay: 28, profile: 'Gregorian', country: 'Australia'),
            ];
          default:
            return const [];
        }

      case 'New Zealand':
        switch (customYear) {
          case 2026:
            return const [
              HolidayItem(name: "Good Friday", gregorianMonth: 4, gregorianDay: 3, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 4, gregorianDay: 6, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "ANZAC Day (Observed)", gregorianMonth: 4, gregorianDay: 27, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "King's Birthday", gregorianMonth: 6, gregorianDay: 1, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Matariki", gregorianMonth: 7, gregorianDay: 10, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Boxing Day (Observed)", gregorianMonth: 12, gregorianDay: 28, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Wellington Anniversary Day", gregorianMonth: 1, gregorianDay: 19, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Auckland Anniversary Day", gregorianMonth: 1, gregorianDay: 26, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Nelson Anniversary Day", gregorianMonth: 2, gregorianDay: 2, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Taranaki Anniversary Day", gregorianMonth: 3, gregorianDay: 9, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Otago Anniversary Day", gregorianMonth: 3, gregorianDay: 23, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Southland Anniversary Day", gregorianMonth: 4, gregorianDay: 7, profile: 'Gregorian', country: 'New Zealand'),
            ];
          case 2027:
            return const [
              HolidayItem(name: "Day After New Year's Day (Observed)", gregorianMonth: 1, gregorianDay: 4, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Waitangi Day (Observed)", gregorianMonth: 2, gregorianDay: 8, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Good Friday", gregorianMonth: 3, gregorianDay: 26, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Easter Monday", gregorianMonth: 3, gregorianDay: 29, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "ANZAC Day (Observed)", gregorianMonth: 4, gregorianDay: 26, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "King's Birthday", gregorianMonth: 6, gregorianDay: 7, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Matariki", gregorianMonth: 6, gregorianDay: 25, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Labour Day", gregorianMonth: 10, gregorianDay: 25, profile: 'Gregorian', country: 'New Zealand'),
              HolidayItem(name: "Boxing Day (Observed)", gregorianMonth: 12, gregorianDay: 27, profile: 'Gregorian', country: 'New Zealand'),
            ];
          default:
            return const [];
        }

      case 'International':
      default:
        return const [];
    }
  }

  static List<HolidayItem> getGregorianHolidays({
    required String? country,
    required int customYear,
  }) {
    final holidays = <HolidayItem>[
      ...baseGregorianHolidays,
      ..._countryRecurringHolidays(country),
      ..._countryYearSpecificHolidays(country, customYear),
    ];

    final seen = <String>{};
    final unique = <HolidayItem>[];

    for (final holiday in holidays) {
      final key = '${holiday.name}|${holiday.gregorianMonth}|${holiday.gregorianDay}|${holiday.country ?? ''}';
      if (seen.add(key)) {
        unique.add(holiday);
      }
    }

    return unique;
  }

  static String _gregorianOffsetLabel({
    required DateTime selectedGregorian,
    required int customYear,
    required HolidayItem holiday,
  }) {
    final holidayYear = _gregorianYearForHolidayInCustomYear(
      customYear,
      holiday.gregorianMonth,
    );

    final holidayDate = DateTime.utc(
      holidayYear,
      holiday.gregorianMonth,
      holiday.gregorianDay,
    );

    final difference = selectedGregorian.difference(holidayDate).inDays;

    if (difference == 0) {
      return '${holiday.name} (Gregorian calendar: same day)';
    }

    if (difference > 0) {
      final unit = difference == 1 ? 'day' : 'days';
      return '${holiday.name} (Gregorian calendar: $difference $unit ago)';
    }

    final daysFromNow = difference.abs();
    final unit = daysFromNow == 1 ? 'day' : 'days';
    return '${holiday.name} (Gregorian calendar: $daysFromNow $unit from now)';
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

    final nominalGregorianMonth =
        _nominalGregorianMonthForCustomMonthIndex(customMonthIndex);

    if (nominalGregorianMonth == null) {
      return [];
    }

    final selectedGregorian = CalendarLogic.convertCustomToGregorianDate(
      customYear: customYear,
      customMonthIndex: customMonthIndex,
      customDay: customDay,
    );

    if (selectedGregorian == null) {
      return [];
    }

    final holidays = getGregorianHolidays(
      country: country,
      customYear: customYear,
    );

    return holidays
        .where(
          (holiday) =>
              holiday.gregorianMonth == nominalGregorianMonth &&
              holiday.gregorianDay == customDay,
        )
        .map(
          (holiday) => _gregorianOffsetLabel(
            selectedGregorian: selectedGregorian,
            customYear: customYear,
            holiday: holiday,
          ),
        )
        .toList();
  }
}

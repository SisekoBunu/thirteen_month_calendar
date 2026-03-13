import '../models/holiday_item.dart';

class IslamicCalendarService {
  static List<HolidayItem> getIslamicHolidays({
    required int customYear,
  }) {
    switch (customYear) {
      case 2025:
        return const [
          HolidayItem(
            name: "Isra and Mi'raj",
            gregorianMonth: 1,
            gregorianDay: 27,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Ramadan Start",
            gregorianMonth: 3,
            gregorianDay: 1,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Laylat al-Qadr",
            gregorianMonth: 3,
            gregorianDay: 27,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Fitr",
            gregorianMonth: 3,
            gregorianDay: 31,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Day of Arafah",
            gregorianMonth: 6,
            gregorianDay: 5,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Adha",
            gregorianMonth: 6,
            gregorianDay: 6,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Islamic New Year",
            gregorianMonth: 6,
            gregorianDay: 26,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Ashura",
            gregorianMonth: 7,
            gregorianDay: 5,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Mawlid al-Nabi",
            gregorianMonth: 9,
            gregorianDay: 5,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
        ];

      case 2026:
        return const [
          HolidayItem(
            name: "Isra and Mi'raj",
            gregorianMonth: 1,
            gregorianDay: 17,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Ramadan Start",
            gregorianMonth: 2,
            gregorianDay: 19,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Laylat al-Qadr",
            gregorianMonth: 3,
            gregorianDay: 15,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Fitr",
            gregorianMonth: 3,
            gregorianDay: 20,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Day of Arafah",
            gregorianMonth: 5,
            gregorianDay: 28,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Adha",
            gregorianMonth: 5,
            gregorianDay: 29,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Islamic New Year",
            gregorianMonth: 6,
            gregorianDay: 18,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Ashura",
            gregorianMonth: 6,
            gregorianDay: 27,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Mawlid al-Nabi",
            gregorianMonth: 8,
            gregorianDay: 26,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
        ];

      case 2027:
        return const [
          HolidayItem(
            name: "Isra and Mi'raj",
            gregorianMonth: 1,
            gregorianDay: 6,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Ramadan Start",
            gregorianMonth: 2,
            gregorianDay: 8,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Laylat al-Qadr",
            gregorianMonth: 3,
            gregorianDay: 6,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Fitr",
            gregorianMonth: 3,
            gregorianDay: 10,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Day of Arafah",
            gregorianMonth: 5,
            gregorianDay: 15,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Adha",
            gregorianMonth: 5,
            gregorianDay: 16,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Islamic New Year",
            gregorianMonth: 6,
            gregorianDay: 6,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Ashura",
            gregorianMonth: 6,
            gregorianDay: 15,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Mawlid al-Nabi",
            gregorianMonth: 8,
            gregorianDay: 15,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
        ];

      default:
        return const [];
    }
  }
}

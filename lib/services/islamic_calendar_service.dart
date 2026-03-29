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
            gregorianDay: 2,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Lailat al-Qadr",
            gregorianMonth: 3,
            gregorianDay: 26,
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
            name: "Eid al-Adha",
            gregorianMonth: 6,
            gregorianDay: 7,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
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
            name: "Laylat al-Barat",
            gregorianMonth: 2,
            gregorianDay: 2,
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
            name: "Lailat al-Qadr",
            gregorianMonth: 3,
            gregorianDay: 16,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Fitr",
            gregorianMonth: 3,
            gregorianDay: 21,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Hajj Begins",
            gregorianMonth: 5,
            gregorianDay: 24,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Day of Arafah",
            gregorianMonth: 5,
            gregorianDay: 26,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic observance',
          ),
          HolidayItem(
            name: "Eid al-Adha",
            gregorianMonth: 5,
            gregorianDay: 27,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Islamic New Year",
            gregorianMonth: 6,
            gregorianDay: 17,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
          HolidayItem(
            name: "Ashura",
            gregorianMonth: 6,
            gregorianDay: 26,
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
            name: "Lailat al-Qadr",
            gregorianMonth: 3,
            gregorianDay: 5,
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
            name: "Eid al-Adha",
            gregorianMonth: 5,
            gregorianDay: 17,
            profile: 'Islamic',
            accuracyLabel: 'tentative',
            category: 'Islamic holiday',
          ),
        ];

      default:
        return const [];
    }
  }
}

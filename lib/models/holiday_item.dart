class HolidayItem {
  final String name;
  final int gregorianMonth;
  final int gregorianDay;
  final String profile;
  final String? country;
  final String? accuracyLabel;
  final String? category;
  final int? timelineYear;

  const HolidayItem({
    required this.name,
    required this.gregorianMonth,
    required this.gregorianDay,
    required this.profile,
    this.country,
    this.accuracyLabel,
    this.category,
    this.timelineYear,
  });
}

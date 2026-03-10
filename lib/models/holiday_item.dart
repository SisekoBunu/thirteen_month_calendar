class HolidayItem {
  final String name;
  final int gregorianMonth;
  final int gregorianDay;
  final String profile;
  final String? country;

  const HolidayItem({
    required this.name,
    required this.gregorianMonth,
    required this.gregorianDay,
    required this.profile,
    this.country,
  });
}

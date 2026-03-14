class CalendarDay {
  final DateTime gregorianDate;
  final int dayNumber;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;

  const CalendarDay({
    required this.gregorianDate,
    required this.dayNumber,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
  });

  CalendarDay copyWith({
    DateTime? gregorianDate,
    int? dayNumber,
    bool? isCurrentMonth,
    bool? isToday,
    bool? isSelected,
  }) {
    return CalendarDay(
      gregorianDate: gregorianDate ?? this.gregorianDate,
      dayNumber: dayNumber ?? this.dayNumber,
      isCurrentMonth: isCurrentMonth ?? this.isCurrentMonth,
      isToday: isToday ?? this.isToday,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

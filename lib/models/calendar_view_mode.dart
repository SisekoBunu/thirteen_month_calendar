enum CalendarViewMode {
  year,
  month,
  day,
}

extension CalendarViewModeExtension on CalendarViewMode {
  String get label {
    switch (this) {
      case CalendarViewMode.year:
        return 'Year';
      case CalendarViewMode.month:
        return 'Month';
      case CalendarViewMode.day:
        return 'Day';
    }
  }
}

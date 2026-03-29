enum CalendarType {
  gregorian,
  christian,islamic,
  thirteenMonth,
}

extension CalendarTypeExtension on CalendarType {
  String get displayName {
    switch (this) {
      case CalendarType.gregorian:
        return 'Gregorian';
      case CalendarType.christian:
        return 'Christian';
      case CalendarType.islamic:
        return 'Islamic';
      case CalendarType.thirteenMonth:
        return '13-Month';
    }
  }

  String get description {
    switch (this) {
      case CalendarType.gregorian:
        return 'Standard civil calendar';
      case CalendarType.christian:
        return 'Christian chronology and holidays';
      case CalendarType.islamic:
        return 'Islamic lunar calendar';
      case CalendarType.thirteenMonth:
        return 'Fixed 13-month calendar';
    }
  }
}


